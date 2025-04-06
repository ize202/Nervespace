import SwiftUI
import SharedKit

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.baseWhite.opacity(0.6))
            
            TextField("Areas, Exercises, Categories, and More", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(Color.baseWhite)
                .tint(.brandPrimary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.baseWhite.opacity(0.6))
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.15))
        .cornerRadius(10)
    }
}

struct CategoryCard: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Icon container
            ZStack {
                Color.white
                Image(systemName: systemImage)
                    .font(.system(size: 40))
                    .foregroundColor(.brandPrimary)
            }
            .frame(height: 120)
            
            // Title container
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.baseBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.white)
        }
        .frame(width: 160)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct AreaCard: View {
    let title: String
    let color: Color
    let imageUrl: String?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background with gradient overlay
            ZStack {
                if let imageUrl = imageUrl {
                    Image(imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay {
                            color.opacity(0.2)
                        }
                } else {
                    color
                }
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.3),
                        .black.opacity(0.1),
                        .clear
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
            
            // Title
            Text(title)
                .font(.system(size: title.count > 15 ? 20 : 24, weight: .bold))
                .foregroundColor(.white)
                .padding(16)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AreaGroup {
    let title: String
    let areas: [ExerciseArea]
    let color: Color
    let imageUrl: String?
}

struct ExploreView: View {
    @State private var searchText = ""
    
    // Grid layout configuration
    private let gridItems = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private let areaGroups: [AreaGroup] = [
        AreaGroup(
            title: "Upper Body",
            areas: [.shoulders, .chest, .upperBack, .neck],
            color: .brandPrimary,
            imageUrl: "exercise_neck_rolls"
        ),
        AreaGroup(
            title: "Core & Back",
            areas: [.core, .lowerBack, .spine, .obliques],
            color: .brandSecondary,
            imageUrl: "exercise_cat_cow"
        ),
        AreaGroup(
            title: "Lower Body",
            areas: [.hips, .hamstrings, .quadriceps, .glutes],
            color: Color(hex: "6B8E23"),
            imageUrl: "exercise_bridge_pose"
        ),
        AreaGroup(
            title: "Arms",
            areas: [.biceps, .triceps, .forearms],
            color: Color(hex: "CD853F"),
            imageUrl: "exercise_bear_hug"
        ),
        AreaGroup(
            title: "Legs",
            areas: [.calves, .knees, .ankles, .feet],
            color: .brandPrimary,
            imageUrl: "exercise_air_squats"
        ),
        AreaGroup(
            title: "Hip Flexors",
            areas: [.psoas, .groin, .itBand, .hips],
            color: .brandSecondary,
            imageUrl: "exercise_butterfly_stretch"
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.baseBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header with bookmark
                        HStack {
                            Text("Explore")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            NavigationLink(destination: BookmarkedRoutinesView()) {
                                Image(systemName: "bookmark")
                                    .foregroundColor(.brandPrimary)
                                    .font(.system(size: 24))
                                    .frame(width: 44, height: 44)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Search Bar
                        SearchBar(text: $searchText)
                            .padding(.horizontal)
                        
                        // Browse by Category
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Browse by Category")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    NavigationLink(destination: CategoryListView(category: .somatic, systemImage: "heart.circle.fill")) {
                                        CategoryCard(title: "Somatic", systemImage: "heart.circle.fill")
                                    }
                                    NavigationLink(destination: CategoryListView(category: .yoga, systemImage: "figure.mind.and.body")) {
                                        CategoryCard(title: "Yoga", systemImage: "figure.mind.and.body")
                                    }
                                    NavigationLink(destination: CategoryListView(category: .mobility, systemImage: "figure.walk")) {
                                        CategoryCard(title: "Mobility", systemImage: "figure.walk")
                                    }
                                    NavigationLink(destination: CategoryListView(category: .staticStretching, systemImage: "figure.flexibility")) {
                                        CategoryCard(title: "Static Stretching", systemImage: "figure.flexibility")
                                    }
                                    NavigationLink(destination: CategoryListView(category: .dynamicStretching, systemImage: "figure.run")) {
                                        CategoryCard(title: "Dynamic Stretching", systemImage: "figure.run")
                                    }
                                    NavigationLink(destination: CategoryListView(category: .isometrics, systemImage: "figure.strengthtraining.traditional")) {
                                        CategoryCard(title: "Isometrics", systemImage: "figure.strengthtraining.traditional")
                                    }
                                    NavigationLink(destination: CategoryListView(category: .calisthenics, systemImage: "figure.highintensity.intervaltraining")) {
                                        CategoryCard(title: "Calisthenics", systemImage: "figure.highintensity.intervaltraining")
                                    }
                                    NavigationLink(destination: CategoryListView(category: .cardio, systemImage: "heart.circle")) {
                                        CategoryCard(title: "Cardio", systemImage: "heart.circle")
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Browse by Area
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Browse by Area")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: gridItems, spacing: 16) {
                                ForEach(areaGroups, id: \.title) { group in
                                    NavigationLink(destination: AreaGroupListView(
                                        title: group.title,
                                        areas: group.areas
                                    )) {
                                        AreaCard(
                                            title: group.title,
                                            color: group.color,
                                            imageUrl: group.imageUrl
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct AreaGroupListView: View {
    let title: String
    let areas: [ExerciseArea]
    @State private var selectedExercise: Exercise?
    
    var exercises: [Exercise] {
        // Get unique exercises that target any of the areas
        Array(Set(areas.flatMap { area in
            ExerciseLibrary.exercises(for: area)
        })).sorted(by: { $0.name < $1.name })
    }
    
    var routines: [Routine] {
        // Get unique routines that contain exercises targeting any of the areas
        Array(Set(areas.flatMap { area in
            RoutineLibrary.routines.filter { routine in
                routine.exercises.contains { routineExercise in
                    routineExercise.exercise.areas.contains(area)
                }
            }
        })).sorted(by: { $0.name < $1.name })
    }
    
    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
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
    ExploreView()
        .preferredColorScheme(.dark)
} 
