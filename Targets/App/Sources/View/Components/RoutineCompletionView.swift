import SwiftUI
import SharedKit
import SupabaseKit

@MainActor
final class RoutineCompletionViewModel: ObservableObject {
    @Published private(set) var completion: Model.RoutineCompletion?
    @Published private(set) var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showConfetti = false
    
    private let completionStore: RoutineCompletionStore
    private let progressStore: LocalProgressStore
    private let syncManager: SupabaseSyncManager
    private let completionId: UUID
    public let routineId: String
    
    init(
        completionStore: RoutineCompletionStore,
        progressStore: LocalProgressStore,
        syncManager: SupabaseSyncManager,
        completionId: UUID,
        routineId: String
    ) {
        self.completionStore = completionStore
        self.progressStore = progressStore
        self.syncManager = syncManager
        self.completionId = completionId
        self.routineId = routineId
        
        // Defer loadData to be called externally
        // This prevents race conditions during initialization
    }
    
    var currentStreak: Int {
        progressStore.streak
    }
    
    func loadData() {
        guard !isLoading else { return }
        
        isLoading = true
        
        // Load completion from local store with retry
        Task { @MainActor in
            // Small delay to ensure completion is in store
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            let recentCompletions = completionStore.getRecentCompletions()
            if let completion = recentCompletions.first(where: { $0.id == completionId }) {
                self.completion = completion
                self.showConfetti = true
            } else {
                print("Warning: Completion \(completionId) not found in store")
                self.showError = true
                self.errorMessage = "Could not load completion details"
            }
            
            self.isLoading = false
            
            // Trigger background sync
            Task {
                await syncManager.syncLocalToSupabase()
            }
        }
    }
}

struct RoutineCompletionView: View {
    let routineId: String
    let completionId: UUID
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RoutineCompletionViewModel
    let onComplete: () -> Void
    
    private let weekDays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    private let calendar = Calendar.current
    
    private var routine: Routine? {
        RoutineLibrary.routines.first { $0.id == routineId }
    }
    
    init(
        routineId: String,
        completionId: UUID,
        progressStore: LocalProgressStore,
        completionStore: RoutineCompletionStore,
        syncManager: SupabaseSyncManager,
        onComplete: @escaping () -> Void
    ) {
        self.routineId = routineId
        self.completionId = completionId
        self.onComplete = onComplete
        self._viewModel = StateObject(wrappedValue: RoutineCompletionViewModel(
            completionStore: completionStore,
            progressStore: progressStore,
            syncManager: syncManager,
            completionId: completionId,
            routineId: routineId
        ))
    }
    
    private var buttonText: String {
        "CONTINUE"
    }
    
    private var isStreakMilestone: Bool {
        viewModel.currentStreak <= 1 || viewModel.currentStreak.isMultiple(of: 7)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.baseBlack.ignoresSafeArea()
            
            if let routine = routine {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Header Text
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Congrats!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("You completed your daily routine.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Streak Card
                        VStack(spacing: 16) {
                            // Streak count
                            Text("\(viewModel.currentStreak) day")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("ACTIVE STREAK")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)
                            
                            // Week view
                            HStack(spacing: 20) {
                                ForEach(Array(weekDays.enumerated()), id: \.offset) { index, day in
                                    VStack(spacing: 8) {
                                        Text(day)
                                            .font(.footnote)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white.opacity(0.6))
                                        
                                        Circle()
                                            .fill(isToday(day) ? .white.opacity(0.2) : Color.white.opacity(0.1))
                                            .frame(width: 32, height: 32)
                                            .overlay {
                                                if isToday(day) {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .padding(.horizontal)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Completed Routine Card with Stats
                        if let completion = viewModel.completion {
                            HStack(spacing: 16) {
                                // Routine Info
                                HStack(spacing: 16) {
                                    // Thumbnail
                                    Image(routine.thumbnailName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(routine.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("\(routine.exercises.count) exercises • \(completion.durationMinutes) min")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                                
                                Spacer()
                                
                                // Checkmark Icon
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 32)
                        
                        // Continue Button
                        Button(action: {
                            dismiss()
                            onComplete()
                        }) {
                            HStack {
                                Text(buttonText)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brandPrimary)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            } else {
                // Fallback view when routine is not found
                VStack(spacing: 16) {
                    Text("Routine Not Found")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("The routine you completed could not be found.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brandPrimary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 32)
                }
                .padding()
            }
            
            // Loading State
            if viewModel.isLoading {
                LoadingOverlay()
            }
            
            // Confetti Layer
            if viewModel.showConfetti {
                ConfettiView(intensity: isStreakMilestone ? .high : .low)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
        }
        .presentationBackground(.clear)
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .task {
            viewModel.loadData()
        }
    }
    
    private func isToday(_ day: String) -> Bool {
        let today = calendar.component(.weekday, from: Date())
        // Convert weekday to our format (Mo = 1, Su = 7)
        let dayIndex = weekDays.firstIndex(of: day)! + 1
        // Convert Sunday from 1 to 7
        let adjustedToday = today == 1 ? 7 : today - 1
        return dayIndex == adjustedToday
    }
}

// Custom Confetti View
struct ConfettiView: View {
    enum Intensity {
        case low
        case high
        
        var pieceCount: Int {
            switch self {
            case .low: return 20
            case .high: return 50
            }
        }
        
        var duration: Double {
            switch self {
            case .low: return 2.0
            case .high: return 3.0
            }
        }
        
        var delayRange: Double {
            switch self {
            case .low: return 0.5
            case .high: return 1.0
            }
        }
    }
    
    let intensity: Intensity
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<intensity.pieceCount) { _ in
                    ConfettiPiece()
                        .position(
                            x: .random(in: 0...geometry.size.width),
                            y: isAnimating ? geometry.size.height + 100 : -100
                        )
                        .animation(
                            Animation.linear(duration: intensity.duration)
                            .repeatForever(autoreverses: false)
                            .delay(.random(in: 0...intensity.delayRange)),
                            value: isAnimating
                        )
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ConfettiPiece: View {
    let colors: [Color] = [.brandPrimary, .blue, .green, .yellow, .pink, .purple, .orange]
    let rotationRange = -360.0...360.0
    let size: CGFloat = 10
    
    var body: some View {
        Circle()
            .fill(colors.randomElement()!)
            .frame(width: size, height: size)
            .rotation3DEffect(
                .degrees(.random(in: rotationRange)),
                axis: (
                    x: .random(in: 0...1),
                    y: .random(in: 0...1),
                    z: .random(in: 0...1)
                )
            )
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
    
    RoutineCompletionView(
        routineId: RoutineLibrary.routines.first!.id,
        completionId: UUID(),
        progressStore: progressStore,
        completionStore: completionStore,
        syncManager: syncManager,
        onComplete: {}
    )
} 
