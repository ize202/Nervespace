import SwiftUI
import SupabaseKit

struct RoutineDetailView: View {
    let routine: Routine
    @State private var exercises: [Exercise]
    @State private var exerciseDurations: [UUID: Int]
    @Environment(\.dismiss) private var dismiss
    
    init(routine: Routine, exercises: [Exercise]) {
        self.routine = routine
        _exercises = State(initialValue: exercises)
        // Initialize with base durations from exercises
        _exerciseDurations = State(initialValue: Dictionary(
            uniqueKeysWithValues: exercises.map { ($0.id, $0.baseDuration) }
        ))
    }
    
    var totalDuration: Int {
        exerciseDurations.values.reduce(0, +)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .center, spacing: 16) {
                Text(routine.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(totalDuration / 60) MINUTES")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                if let description = routine.description {
                    Text(description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: Add to favorites
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.primary)
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

struct ExerciseRow: View {
    let exercise: Exercise
    @Binding var duration: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Exercise Icon/Thumbnail
            if let thumbnailURL = exercise.thumbnailURL {
                AsyncImage(url: thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                
                if let description = exercise.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Duration Controls
            HStack(spacing: 12) {
                Button(action: { duration = max(0, duration - 30) }) {
                    Image(systemName: "minus")
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Text("\(duration / 60):\(String(format: "%02d", duration % 60))")
                    .font(.headline)
                    .monospacedDigit()
                
                Button(action: { duration += 30 }) {
                    Image(systemName: "plus")
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        RoutineDetailView(
            routine: .mockWakeAndShake,
            exercises: Dictionary.mockRoutineExercises[Routine.mockWakeAndShake.id] ?? []
        )
    }
} 