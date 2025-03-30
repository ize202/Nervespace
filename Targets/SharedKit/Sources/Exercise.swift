import Foundation

public struct Exercise: Identifiable, Hashable {
    public let id: String // Using name as ID
    public let name: String
    public let description: String
    public let instructions: String
    public let modifications: String?
    public let benefits: String
    public let categories: [ExerciseCategory]
    public let positions: [ExercisePosition]
    public let areas: [ExerciseArea]
    public let duration: Int // in seconds
    
    public init(
        name: String,
        description: String,
        instructions: String,
        modifications: String? = nil,
        benefits: String,
        categories: [ExerciseCategory],
        positions: [ExercisePosition],
        areas: [ExerciseArea],
        duration: Int
    ) {
        self.id = name.lowercased().replacingOccurrences(of: " ", with: "_")
        self.name = name
        self.description = description
        self.instructions = instructions
        self.modifications = modifications
        self.benefits = benefits
        self.categories = categories
        self.positions = positions
        self.areas = areas
        self.duration = duration
    }
    
    public var thumbnailName: String {
        "exercise_\(id)"
    }
} 