import SwiftUI
import SharedKit
import SupabaseKit

public struct RoutineDetailView: View {
    let routine: Routine
    let previewMode: Bool
    @State private var exerciseDurations: [String: Int]
    @State private var showingActiveSession = false
    @State private var selectedExercise: Exercise?
    @StateObject private var bookmarkManager = BookmarkManager.shared
    
    // Local-first dependencies
    @EnvironmentObject private var progressStore: LocalProgressStore
    @EnvironmentObject private var completionStore: RoutineCompletionStore
    @EnvironmentObject private var syncManager: SupabaseSyncManager
    
    public init(routine: Routine, previewMode: Bool = false) {
        self.routine = routine
        self.previewMode = previewMode
        _exerciseDurations = State(initialValue: Dictionary(
            uniqueKeysWithValues: routine.exercises.map { ($0.exercise.id, $0.duration) }
        ))
    }
    
    var totalDuration: Int {
        exerciseDurations.values.reduce(0, +)
    }
    
    public var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(routine.name)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(totalDuration / 60) MINUTES")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(routine.description)
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.7))
                        .lineSpacing(4)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
                
                // Exercise List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(routine.exercises) { routineExercise in
                            ExerciseRow(
                                exercise: routineExercise.exercise,
                                duration: exerciseDurationBinding(for: routineExercise.exercise),
                                onTap: { selectedExercise = routineExercise.exercise }
                            )
                        }
                    }
                    .padding()
                }
                
                // Start Button
                if !previewMode {
                    Button(action: {
                        showingActiveSession = true
                    }) {
                        Text("START")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brandPrimary)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !previewMode {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        bookmarkManager.toggleBookmark(for: routine)
                    }) {
                        Image(systemName: bookmarkManager.isBookmarked(routine) ? "bookmark.fill" : "bookmark")
                            .foregroundColor(.brandPrimary)
                            .font(.system(size: 20))
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
        .fullScreenCover(isPresented: $showingActiveSession) {
            ActiveSessionView(
                routine: routine,
                customDurations: exerciseDurations,
                progressStore: progressStore,
                completionStore: completionStore,
                syncManager: syncManager
            )
        }
    }
    
    private func exerciseDurationBinding(for exercise: Exercise) -> Binding<Int> {
        Binding(
            get: { exerciseDurations[exercise.id] ?? 0 },
            set: { exerciseDurations[exercise.id] = $0 }
        )
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise
    @Binding var duration: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Thumbnail
                Image(exercise.thumbnailName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Exercise Name
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Duration Controls
                DurationControls(duration: $duration)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct DurationControls: View {
    @Binding var duration: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: { duration = max(0, duration - 30) }) {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.2)).frame(width: 28, height: 28))
            }
            
            Text("\(duration / 60):\(String(format: "%02d", duration % 60))")
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(minWidth: 45)
            
            Button(action: { duration += 30 }) {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.2)).frame(width: 28, height: 28))
            }
        }
        .contentShape(Rectangle())
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
    
    RoutineDetailView(routine: RoutineLibrary.routines.first!)
        .environmentObject(progressStore)
        .environmentObject(completionStore)
        .environmentObject(pendingStore)
        .environmentObject(syncManager)
} 