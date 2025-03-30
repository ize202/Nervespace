import Foundation

public enum RoutineLibrary {
    // MARK: - All Routines
    public static let routines: [Routine] = [
        // Core Routines (5-7 minutes)
        Routine(
            name: "Morning Boost",
            description: "Energize your body and mind to start the day.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Jumping Jacks" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "High Knees" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Air Squats" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Warrior I" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Deep Breathing" }!, duration: 60)
            ],
            category: .core,
            difficulty: .beginner,
            timeOfDay: .morning
        ),
        
        Routine(
            name: "Full Body",
            description: "A comprehensive routine to activate the entire body.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Plank Hold" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Seated Side Bends" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Downward Dog" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Bridge Pose" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Bear Hug" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Child's Pose" }!, duration: 30)
            ],
            category: .core,
            difficulty: .intermediate,
            timeOfDay: .midday
        ),
        
        Routine(
            name: "Evening Calm",
            description: "Relax and release tension before bed.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Deep Breathing" }!, duration: 60),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Seated Forward Fold" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Lying Figure Four" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Happy Baby Pose" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Cat Cow" }!, duration: 60)
            ],
            category: .core,
            difficulty: .beginner,
            timeOfDay: .evening
        ),
        
        Routine(
            name: "Posture Reset",
            description: "Improve posture and alleviate tension from sitting.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Neck Rolls" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Bear Hug" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Wall Sit" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Bridge Pose" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Hip Circles" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Deep Breathing" }!, duration: 60)
            ],
            category: .core,
            difficulty: .beginner,
            timeOfDay: .midday
        ),
        
        Routine(
            name: "Somatic Ease",
            description: "Calm the nervous system and promote relaxation.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Deep Breathing" }!, duration: 60),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Cat Cow" }!, duration: 60),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Child's Pose" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Happy Baby Pose" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Butterfly Stretch" }!, duration: 30)
            ],
            category: .core,
            difficulty: .beginner,
            timeOfDay: nil
        ),
        
        // Quick Routines (3-5 minutes)
        Routine(
            name: "Quick Refresh",
            description: "Boost energy and focus quickly.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "High Knees" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Air Squats" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Seated Side Bends" }!, duration: 30)
            ],
            category: .quick,
            difficulty: .beginner
        ),
        
        Routine(
            name: "Rapid Relax",
            description: "Fast-track to relaxation and stress relief.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Deep Breathing" }!, duration: 60),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Seated Forward Fold" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Neck Rolls" }!, duration: 30)
            ],
            category: .quick,
            difficulty: .beginner
        ),
        
        Routine(
            name: "Core Focus",
            description: "Engage and strengthen the core swiftly.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Plank Hold" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Wall Sit" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Bridge Pose" }!, duration: 30)
            ],
            category: .quick,
            difficulty: .intermediate
        ),
        
        Routine(
            name: "Flex Quick",
            description: "Enhance flexibility in minimal time.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Lying Figure Four" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Butterfly Stretch" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Downward Dog" }!, duration: 30)
            ],
            category: .quick,
            difficulty: .beginner
        ),
        
        Routine(
            name: "Energy Surge",
            description: "Quickly revitalize and invigorate the body.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Jumping Jacks" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Leg Swings" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Seated Side Bends" }!, duration: 30)
            ],
            category: .quick,
            difficulty: .intermediate
        )
    ]
    
    // MARK: - Premium Status
    public static var freeRoutines: [Routine] {
        routines.filter { !$0.isPremium }
    }
    
    public static var premiumRoutines: [Routine] {
        routines.filter { $0.isPremium }
    }
    
    // MARK: - Duration Helpers
    public static var shortRoutines: [Routine] {
        routines.filter { $0.totalDuration <= 300 } // 5 minutes or less
    }
    
    public static var mediumRoutines: [Routine] {
        routines.filter { $0.totalDuration > 300 && $0.totalDuration <= 900 } // 5-15 minutes
    }
    
    public static var longRoutines: [Routine] {
        routines.filter { $0.totalDuration > 900 } // more than 15 minutes
    }
    
    // MARK: - Search Helpers
    public static func search(_ query: String) -> [Routine] {
        let terms = query.lowercased().split(separator: " ").map(String.init)
        return routines.filter { routine in
            terms.contains { term in
                routine.name.lowercased().contains(term) ||
                routine.description.lowercased().contains(term) ||
                routine.exercises.contains { 
                    $0.exercise.name.lowercased().contains(term)
                }
            }
        }
    }
    
    // MARK: - Category Helpers
    public static func routines(for category: RoutineCategory) -> [Routine] {
        routines.filter { $0.category == category }
    }
    
    public static var coreRoutines: [Routine] {
        routines(for: .core)
    }
    
    public static var quickRoutines: [Routine] {
        routines(for: .quick)
    }
    
    // MARK: - Difficulty Helpers
    public static func routines(withDifficulty difficulty: RoutineDifficulty) -> [Routine] {
        routines.filter { $0.difficulty == difficulty }
    }
    
    public static var beginnerRoutines: [Routine] {
        routines(withDifficulty: .beginner)
    }
    
    public static var intermediateRoutines: [Routine] {
        routines(withDifficulty: .intermediate)
    }
    
    public static var advancedRoutines: [Routine] {
        routines(withDifficulty: .advanced)
    }
    
    // MARK: - Time of Day Helpers
    public static func routines(forTimeOfDay timeOfDay: TimeOfDay) -> [Routine] {
        routines.filter { $0.timeOfDay == timeOfDay }
    }
    
    public static var morningRoutines: [Routine] {
        routines(forTimeOfDay: .morning)
    }
    
    public static var middayRoutines: [Routine] {
        routines(forTimeOfDay: .midday)
    }
    
    public static var eveningRoutines: [Routine] {
        routines(forTimeOfDay: .evening)
    }
    
    // MARK: - Combined Filters
    public static func routines(
        category: RoutineCategory? = nil,
        difficulty: RoutineDifficulty? = nil,
        timeOfDay: TimeOfDay? = nil
    ) -> [Routine] {
        routines.filter { routine in
            (category == nil || routine.category == category) &&
            (difficulty == nil || routine.difficulty == difficulty) &&
            (timeOfDay == nil || routine.timeOfDay == timeOfDay)
        }
    }
    
    // MARK: - Exercise Category Helpers
    public static func routines(withExerciseCategory category: ExerciseCategory) -> [Routine] {
        routines.filter { routine in
            routine.exercises.contains { exercise in
                exercise.exercise.categories.contains(category)
            }
        }
    }
    
    // Static Stretching
    public static var staticStretchingRoutines: [Routine] {
        routines(withExerciseCategory: .staticStretching)
    }
    
    // Dynamic Stretching
    public static var dynamicStretchingRoutines: [Routine] {
        routines(withExerciseCategory: .dynamicStretching)
    }
    
    // Isometrics
    public static var isometricsRoutines: [Routine] {
        routines(withExerciseCategory: .isometrics)
    }
    
    // Somatic
    public static var somaticRoutines: [Routine] {
        routines(withExerciseCategory: .somatic)
    }
    
    // Calisthenics
    public static var calisthenicsRoutines: [Routine] {
        routines(withExerciseCategory: .calisthenics)
    }
    
    // Mobility
    public static var mobilityRoutines: [Routine] {
        routines(withExerciseCategory: .mobility)
    }
    
    // Yoga
    public static var yogaRoutines: [Routine] {
        routines(withExerciseCategory: .yoga)
    }
    
    // Cardio
    public static var cardioRoutines: [Routine] {
        routines(withExerciseCategory: .cardio)
    }
} 
