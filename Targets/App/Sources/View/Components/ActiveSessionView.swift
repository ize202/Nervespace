import SwiftUI
import SharedKit
import SupabaseKit

public struct ActiveSessionView: View {
    let routine: Routine
    let customDurations: [String: Int]
    @State private var currentExerciseIndex: Int = 0
    @State private var timeRemaining: Int
    @State private var isPaused: Bool = false
    @State private var timer: Timer?
    @State private var animationId: UUID = UUID()
    @Environment(\.dismiss) private var dismiss
    @State private var progressValue: Double = 0
    @State private var showExerciseDetail = false
    @State private var showingCompletion = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var completionData: (id: UUID, routineId: String)?
    @State private var isUpdating = false
    @State private var sessionStartTime: Date = Date()
    @State private var totalPausedTime: TimeInterval = 0
    @State private var lastPauseTime: Date?
    @State private var completedRoutineId: String?
    @Environment(\.presentationMode) private var presentationMode
    let onSessionComplete: () -> Void
    
    // Local-first dependencies
    private let progressStore: LocalProgressStore
    private let completionStore: RoutineCompletionStore
    private let syncManager: SupabaseSyncManager
    
    public init(
        routine: Routine,
        customDurations: [String: Int],
        progressStore: LocalProgressStore,
        completionStore: RoutineCompletionStore,
        syncManager: SupabaseSyncManager,
        onSessionComplete: @escaping () -> Void
    ) {
        self.routine = routine
        self.customDurations = customDurations
        self.progressStore = progressStore
        self.completionStore = completionStore
        self.syncManager = syncManager
        self.onSessionComplete = onSessionComplete
        // Initialize with the first exercise duration
        _timeRemaining = State(initialValue: routine.exercises.first.map { customDurations[$0.exercise.id] ?? $0.duration } ?? 30)
    }
    
    private var currentRoutineExercise: RoutineExercise? {
        guard routine.exercises.indices.contains(currentExerciseIndex) else { return nil }
        return routine.exercises[currentExerciseIndex]
    }
    
    private var currentExercise: Exercise? {
        currentRoutineExercise?.exercise
    }
    
    private var progressText: String {
        "\(currentExerciseIndex + 1) of \(routine.exercises.count)"
    }
    
    private var actualSessionDuration: TimeInterval {
        guard !isPaused else {
            if let lastPause = lastPauseTime {
                return lastPause.timeIntervalSince(sessionStartTime) - totalPausedTime
            }
            return 0
        }
        return Date().timeIntervalSince(sessionStartTime) - totalPausedTime
    }
    
    public var body: some View {
        ZStack {
            // Background
            Color.baseBlack.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(Color.baseWhite)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text(progressText)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color.baseWhite)
                    
                    Spacer()
                    
                          // Button(action: {
                    //     // TODO: Show more options
                    // }) {
                    //     Image(systemName: "gear")
                    //         .font(.system(size: 20))
                    //         .foregroundColor(Color.baseWhite)
                    //         .frame(width: 44, height: 44)
                    // }
                    
                    // Placeholder view to maintain symmetry
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Exercise Animation/Image
                ZStack {
                    // Exercise Image
                    if let exercise = currentExercise {
                        Image(exercise.thumbnailName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 280, height: 280)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    } else {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 280, height: 280)
                    }
                    
                    // Timer Progress Indicator
                    RoundedRectangle(cornerRadius: 24)
                        .trim(from: 0, to: progressValue)
                        .stroke(Color.brandPrimary, lineWidth: 12)
                        .frame(width: 280, height: 280)
                        .rotationEffect(.degrees(-90))
                        .transaction { transaction in
                            if transaction.animation != nil {
                                // Only animate when updating progress, not during resets
                                transaction.animation = transaction.animation?.speed(progressValue == 0 ? 100 : 1)
                            }
                        }
                        .animation(.none, value: currentExerciseIndex)
                        .animation(.linear(duration: 1), value: progressValue)
                        .id(animationId)
                }
                
                // Exercise Name
                HStack {
                    Text(currentExercise?.name ?? "")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color.baseWhite)
                    
                    Button(action: {
                        showExerciseDetail = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                            .foregroundColor(Color.baseWhite.opacity(0.6))
                            .frame(width: 44, height: 44)
                    }
                }
                
                // Timer
                Text(timeString(from: timeRemaining))
                    .font(.system(size: 72, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.baseWhite)
                    .padding(.top, 32)
                
                Spacer()
                
                // Playback Controls
                HStack(spacing: 40) {
                    Button(action: previousExercise) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    
                    Button(action: togglePause) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    
                    Button(action: nextExercise) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                }
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        .sheet(isPresented: $showExerciseDetail) {
            if let exercise = currentExercise {
                ExerciseDetailView(exercise: exercise)
            }
        }
        .sheet(isPresented: $showingCompletion) {
            if let data = completionData {
                RoutineCompletionView(
                    routineId: data.routineId,
                    completionId: data.id,
                    progressStore: progressStore,
                    completionStore: completionStore,
                    syncManager: syncManager,
                    onComplete: {
                        dismiss()
                        onSessionComplete()
                    }
                )
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func updateProgress() {
        guard let routineExercise = currentRoutineExercise else { return }
        let duration = Double(customDurations[routineExercise.exercise.id] ?? routineExercise.duration)
        let remaining = Double(timeRemaining)
        // Ensure we reach exactly 1.0 when time is up
        let progress = remaining <= 0 ? 1.0 : 1.0 - (remaining / duration)
        
        withAnimation(.linear(duration: 1)) {
            progressValue = progress
        }
    }
    
    private func completeRoutine() async {
        guard !isUpdating else { 
            print("[ActiveSession] Skipping completion - already updating")
            return 
        }
        
        await MainActor.run {
            isUpdating = true
        }
        
        do {
            // Calculate actual duration in minutes, rounded up
            let durationMinutes = Int(ceil(actualSessionDuration / 60.0))
            print("[ActiveSession] Completing routine: id=\(routine.id), duration=\(durationMinutes)m")
            
            // Get current user ID
            guard let userId = syncManager.db.currentUser?.id else {
                throw NSError(domain: "ActiveSessionView", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
            }
            print("[ActiveSession] User authenticated: \(userId)")
            
            // Create completion record
            let completion = Model.RoutineCompletion(
                id: UUID(),
                userId: userId,
                routineId: routine.id,
                completedAt: Date(),
                durationMinutes: durationMinutes
            )
            print("[ActiveSession] Created completion record: id=\(completion.id)")
            
            // Save to local store and update UI state atomically
            await MainActor.run {
                print("[ActiveSession] Saving to local store...")
                // Update stores first
                completionStore.addCompletion(completion)
                progressStore.addCompletion(durationMinutes: durationMinutes)
                
                print("[ActiveSession] Updating view state...")
                // Then update view state
                completionData = (id: completion.id, routineId: routine.id)
                
                // Finally show the sheet
                showingCompletion = true
                print("[ActiveSession] Sheet presentation triggered")
            }
            
            // Background sync
            print("[ActiveSession] Starting background sync...")
            Task.detached {
                do {
                    print("[ActiveSession] Syncing to Supabase...")
                    await syncManager.syncLocalToSupabase()
                    print("[ActiveSession] Sync completed successfully")
                } catch {
                    print("[ActiveSession] Sync failed: \(error)")
                    print("[ActiveSession] Adding to pending sync...")
                    await syncManager.handleFailedSync(completion)
                }
            }
        } catch {
            print("[ActiveSession] Error completing routine: \(error)")
            await MainActor.run {
                showError = true
                errorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            isUpdating = false
        }
    }

    private func startTimer() {
        guard timer == nil else { return }
        updateProgress() // Initial progress update
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard !isPaused else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
                updateProgress()
            } else {
                // Time's up for current exercise
                if currentExerciseIndex < routine.exercises.count - 1 {
                    // Move to next exercise
                    nextExercise()
                } else {
                    // Workout complete
                    timer?.invalidate()
                    timer = nil
                    Task {
                        await completeRoutine()
                    }
                }
            }
        }
    }
    
    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            lastPauseTime = Date()
            timer?.invalidate()
            timer = nil
        } else {
            if let lastPause = lastPauseTime {
                totalPausedTime += Date().timeIntervalSince(lastPause)
            }
            lastPauseTime = nil
            startTimer()
        }
    }
    
    private func nextExercise() {
        guard currentExerciseIndex < routine.exercises.count - 1 else { return }
        progressValue = 0 // Reset progress immediately without animation wrapper
        currentExerciseIndex += 1
        if let routineExercise = currentRoutineExercise {
            timeRemaining = customDurations[routineExercise.exercise.id] ?? routineExercise.duration
        }
        // Small delay to ensure reset is complete before starting new animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            updateProgress()
        }
    }
    
    private func previousExercise() {
        guard currentExerciseIndex > 0 else { return }
        progressValue = 0 // Reset progress immediately without animation wrapper
        currentExerciseIndex -= 1
        if let routineExercise = currentRoutineExercise {
            timeRemaining = customDurations[routineExercise.exercise.id] ?? routineExercise.duration
        }
        // Small delay to ensure reset is complete before starting new animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            updateProgress()
        }
    }
}

#Preview {
    let progressStore = LocalProgressStore()
    let completionStore = RoutineCompletionStore()
    let pendingStore = PendingCompletionStore()
    let db = DB()
    let syncManager = SupabaseSyncManager(
        db: db,
        progressStore: progressStore,
        completionStore: completionStore,
        pendingStore: pendingStore
    )
    
    ActiveSessionView(
        routine: RoutineLibrary.routines.first!,
        customDurations: [:],
        progressStore: progressStore,
        completionStore: completionStore,
        syncManager: syncManager,
        onSessionComplete: {}
    )
} 
