import SwiftUI
import SupabaseKit

public struct RoutineDetailView: View {
    let routine: Routine
    let exercises: [Exercise]
    let isModal: Bool
    @State private var exerciseDurations: [UUID: Int]
    @Environment(\.dismiss) private var dismiss
    
    public init(routine: Routine, exercises: [Exercise], isModal: Bool = false) {
        self.routine = routine
        self.exercises = exercises
        self.isModal = isModal
        _exerciseDurations = State(initialValue: Dictionary(
            uniqueKeysWithValues: exercises.map { ($0.id, $0.baseDuration) }
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
                    
                    Text("\(totalDuration / 60) MINUTES")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                    
                    if let description = routine.description {
                        Text(description)
                            .font(.system(size: 17))
                            .foregroundColor(.white.opacity(0.7))
                            .lineSpacing(4)
                            .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 24)
                
                // Exercise List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(exercises) { exercise in
                            ExerciseRow(
                                exercise: exercise,
                                duration: exerciseDurationBinding(for: exercise)
                            )
                        }
                    }
                    .padding()
                }
                
                // Start Button
                Button(action: {
                    // TODO: Start workout
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isModal {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: Add to favorites
                }) {
                    Image(systemName: "bookmark")
                        .foregroundColor(.brandPrimary)
                        .font(.system(size: 24))
                }
            }
        }
    }
    
    private func exerciseDurationBinding(for exercise: Exercise) -> Binding<Int> {
        Binding(
            get: { exerciseDurations[exercise.id] ?? exercise.baseDuration },
            set: { exerciseDurations[exercise.id] = $0 }
        )
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise
    @Binding var duration: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let thumbnailURL = exercise.thumbnailURL {
                AsyncImage(url: thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 56, height: 56)
            }
            
            // Exercise Name
            Text(exercise.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            // Duration Controls
            HStack(spacing: 8) {
                Button(action: { duration = max(0, duration - 30) }) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
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
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        }
    }
}

#Preview {
    NavigationView {
        RoutineDetailView(
            routine: .mockWakeAndShake,
            exercises: Dictionary.mockRoutineExercises[Routine.mockWakeAndShake.id] ?? []
        )
    }
    .preferredColorScheme(.dark)
} 