import Foundation

public struct RoutineExercise: Identifiable, Hashable {
    public let id: String
    public let exercise: Exercise
    public let duration: Int // in seconds
    
    public init(exercise: Exercise, duration: Int) {
        self.id = UUID().uuidString
        self.exercise = exercise
        self.duration = duration
    }
}

public struct Routine: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let isPremium: Bool
    public let exercises: [RoutineExercise]
    
    public init(
        name: String,
        description: String,
        isPremium: Bool = false,
        exercises: [RoutineExercise]
    ) {
        self.id = name.lowercased().replacingOccurrences(of: " ", with: "_")
        self.name = name
        self.description = description
        self.isPremium = isPremium
        self.exercises = exercises
    }
    
    public var thumbnailName: String {
        "routine_\(id)"
    }
    
    public var totalDuration: Int {
        exercises.reduce(0) { $0 + $1.duration }
    }
} 