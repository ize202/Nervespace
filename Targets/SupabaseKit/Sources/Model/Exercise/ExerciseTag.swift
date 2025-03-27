import Foundation

public struct ExerciseTag: Identifiable, Codable, Hashable {
    public var id: String { "\(exerciseId)-\(tag)" }
    public let exerciseId: UUID
    public let tag: String
    
    public init(exerciseId: UUID, tag: String) {
        self.exerciseId = exerciseId
        self.tag = tag
    }
    
    enum CodingKeys: String, CodingKey {
        case exerciseId = "exercise_id"
        case tag
    }
} 