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
            ]
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
            ]
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
            ]
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
            ]
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
            ]
        ),
        
        // Quick Routines (3-5 minutes)
        Routine(
            name: "Quick Refresh",
            description: "Boost energy and focus quickly.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "High Knees" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Air Squats" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Seated Side Bends" }!, duration: 30)
            ]
        ),
        
        Routine(
            name: "Rapid Relax",
            description: "Fast-track to relaxation and stress relief.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Deep Breathing" }!, duration: 60),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Seated Forward Fold" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Neck Rolls" }!, duration: 30)
            ]
        ),
        
        Routine(
            name: "Core Focus",
            description: "Engage and strengthen the core swiftly.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Plank Hold" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Wall Sit" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Bridge Pose" }!, duration: 30)
            ]
        ),
        
        Routine(
            name: "Flex Quick",
            description: "Enhance flexibility in minimal time.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Lying Figure Four" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Butterfly Stretch" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Downward Dog" }!, duration: 30)
            ]
        ),
        
        Routine(
            name: "Energy Surge",
            description: "Quickly revitalize and invigorate the body.",
            exercises: [
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Jumping Jacks" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Leg Swings" }!, duration: 30),
                RoutineExercise(exercise: ExerciseLibrary.exercises.first { $0.name == "Dynamic Side Bends" }!, duration: 30)
            ]
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
    public static var quickRoutines: [Routine] {
        routines.filter { $0.totalDuration <= 300 } // 5 minutes or less
    }
    
    public static var mediumRoutines: [Routine] {
        routines.filter { $0.totalDuration > 300 && $0.totalDuration <= 900 } // 5-15 minutes
    }
    
    public static var longRoutines: [Routine] {
        routines.filter { $0.totalDuration > 900 } // more than 15 minutes
    }
    
    // MARK: - Search Helpers
    public static func routine(withId id: String) -> Routine? {
        routines.first { $0.id == id }
    }
    
    public static func search(_ query: String) -> [Routine] {
        let terms = query.lowercased().split(separator: " ").map(String.init)
        return routines.filter { routine in
            terms.contains { term in
                routine.name.lowercased().contains(term) ||
                routine.description.lowercased().contains(term) ||
                routine.exercises.contains { 
                    $0.exercise.name.lowercased().contains(term) ||
                    $0.exercise.categories.contains { $0.rawValue.lowercased().contains(term) }
                }
            }
        }
    }
    
    // MARK: - Category Helpers
    public static func routines(containing category: ExerciseCategory) -> [Routine] {
        routines.filter { routine in
            routine.exercises.contains { 
                $0.exercise.categories.contains(category)
            }
        }
    }
    
    public static var somaticRoutines: [Routine] {
        routines(containing: .somatic)
    }
    
    public static var mobilityRoutines: [Routine] {
        routines(containing: .mobility)
    }
} 