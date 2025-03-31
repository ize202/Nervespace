import Foundation

public struct UserProgress: Identifiable, Codable, Hashable {
    public let id: UUID
    public let userId: UUID?
    public let deviceId: UUID?
    public let streak: Int
    public let routineCompletions: Int
    public let totalMinutes: Int
    public let lastActivity: Date?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID? = nil,
        deviceId: UUID? = nil,
        streak: Int = 0,
        routineCompletions: Int = 0,
        totalMinutes: Int = 0,
        lastActivity: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.deviceId = deviceId
        self.streak = streak
        self.routineCompletions = routineCompletions
        self.totalMinutes = totalMinutes
        self.lastActivity = lastActivity
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Convenience initializer for authenticated users
    public init(userId: UUID) {
        self.init(userId: userId, deviceId: nil)
    }
    
    // Convenience initializer for anonymous users
    public init(deviceId: UUID) {
        self.init(userId: nil, deviceId: deviceId)
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case deviceId = "device_id"
        case streak
        case routineCompletions = "routine_completions"
        case totalMinutes = "total_minutes"
        case lastActivity = "last_activity"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 