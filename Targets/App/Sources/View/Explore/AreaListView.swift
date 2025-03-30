import SwiftUI
import SharedKit

struct AreaListView: View {
    let area: ExerciseArea
    let color: Color
    @State private var selectedExercise: Exercise?
    
    private var exercises: [Exercise] {
        ExerciseLibrary.exercises.filter { exercise in
            exercise.areas.contains(area)
        }
    }
    
    private var routines: [Routine] {
        RoutineLibrary.routines.filter { routine in
            routine.exercises.contains { routineExercise in
                routineExercise.exercise.areas.contains(area)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(area.rawValue)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(exercises.count + routines.count) ITEMS")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 24)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if !exercises.isEmpty {
                            Text("Exercises")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            ForEach(exercises) { exercise in
                                Button(action: { selectedExercise = exercise }) {
                                    ExerciseRow(exercise: exercise)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        
                        if !routines.isEmpty {
                            Text("Routines")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.top, exercises.isEmpty ? 0 : 16)
                            
                            ForEach(routines) { routine in
                                NavigationLink(destination: RoutineDetailView(routine: routine)) {
                                    RoutineRow(routine: routine)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            Image(exercise.thumbnailName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(exercise.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(exercise.duration / 60) min")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        }
    }
}

private struct RoutineRow: View {
    let routine: Routine
    
    var body: some View {
        HStack(spacing: 12) {
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
                
                Text("\(routine.exercises.count) exercises • \(routine.totalDuration / 60) min")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
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
        AreaListView(
            area: .core,
            color: .brandPrimary
        )
    }
    .preferredColorScheme(.dark)
} 