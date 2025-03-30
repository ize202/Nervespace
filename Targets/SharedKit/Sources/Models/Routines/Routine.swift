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
    public let category: RoutineCategory
    public let difficulty: RoutineDifficulty
    public let timeOfDay: TimeOfDay?
    
    public init(
        name: String,
        description: String,
        isPremium: Bool = false,
        exercises: [RoutineExercise],
        category: RoutineCategory = .core,
        difficulty: RoutineDifficulty = .beginner,
        timeOfDay: TimeOfDay? = nil
    ) {
        self.id = name.lowercased().replacingOccurrences(of: " ", with: "_")
        self.name = name
        self.description = description
        self.isPremium = isPremium
        self.exercises = exercises
        self.category = category
        self.difficulty = difficulty
        self.timeOfDay = timeOfDay
    }
    
    public var thumbnailName: String {
        "routine_\(id)"
    }
    
    public var totalDuration: Int {
        exercises.reduce(0) { $0 + $1.duration }
    }
}

public enum RoutineCategory: String, CaseIterable {
    case core = "Core"
    case quick = "Quick"
    case custom = "Custom"
}

public enum RoutineDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

public enum TimeOfDay: String, CaseIterable {
    case morning = "Morning"
    case midday = "Midday"
    case evening = "Evening"
} 