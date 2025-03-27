import SwiftUI
import SupabaseKit

struct CategoryListView: View {
    let category: String
    let systemImage: String
    @State private var routines: [Routine] = []
    @State private var exercises: [Exercise] = []
    @State private var isLoading = true
    @State private var selectedExercise: Exercise?
    
    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(category)
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
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.brandPrimary)
                    Spacer()
                } else {
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
                                    NavigationLink(destination: RoutineDetailView(
                                        routine: routine,
                                        exercises: Dictionary.mockRoutineExercises[routine.id] ?? []
                                    )) {
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise)
        }
        .task {
            // Simulate API call with mock data for now
            try? await Task.sleep(for: .seconds(1))
            routines = [.mockWakeAndShake, .mockEveningUnwind]
            exercises = Exercise.allMocks.filter { exercise in
                Dictionary.mockExerciseTags[exercise.id]?.contains(category) ?? false
            }
            isLoading = false
        }
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise
    
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
            
            Text(exercise.name)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("\(exercise.baseDuration / 60) min")
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
            if let thumbnailURL = routine.thumbnailURL {
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
            
            Text(routine.name)
                .font(.headline)
                .foregroundColor(.white)
            
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
        CategoryListView(category: "Meditation", systemImage: "heart.circle.fill")
    }
    .preferredColorScheme(.dark)
} 