import Foundation

public struct UserProgress: Identifiable, Codable, Hashable {
    public let id: UUID
    public let userId: UUID
    public let streak: Int
    public let routineCompletions: Int
    public let totalMinutes: Int
    public let lastActivity: Date?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID,
        streak: Int = 0,
        routineCompletions: Int = 0,
        totalMinutes: Int = 0,
        lastActivity: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.streak = streak
        self.routineCompletions = routineCompletions
        self.totalMinutes = totalMinutes
        self.lastActivity = lastActivity
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case streak
        case routineCompletions = "routine_completions"
        case totalMinutes = "total_minutes"
        case lastActivity = "last_activity"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 