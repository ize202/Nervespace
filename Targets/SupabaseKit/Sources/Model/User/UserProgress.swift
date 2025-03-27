import Foundation

public struct UserProgress: Identifiable, Codable, Hashable {
    public let id: UUID
    public let userId: UUID
    public let exerciseId: UUID?
    public let routineId: UUID?
    public let completedAt: Date
    public let duration: Int
    
    public init(
        id: UUID,
        userId: UUID,
        exerciseId: UUID?,
        routineId: UUID?,
        completedAt: Date,
        duration: Int
    ) {
        self.id = id
        self.userId = userId
        self.exerciseId = exerciseId
        self.routineId = routineId
        self.completedAt = completedAt
        self.duration = duration
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case exerciseId = "exercise_id"
        case routineId = "routine_id"
        case completedAt = "completed_at"
        case duration
    }
} 