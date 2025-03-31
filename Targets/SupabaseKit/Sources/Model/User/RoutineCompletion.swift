import Foundation

public struct RoutineCompletion: Identifiable, Codable, Hashable {
    public let id: UUID
    public let userId: UUID?
    public let deviceId: UUID?
    public let routineId: String
    public let completedAt: Date
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: UUID? = nil,
        deviceId: UUID? = nil,
        routineId: String,
        completedAt: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.deviceId = deviceId
        self.routineId = routineId
        self.completedAt = completedAt
        self.createdAt = createdAt
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case deviceId = "device_id"
        case routineId = "routine_id"
        case completedAt = "completed_at"
        case createdAt = "created_at"
    }
} 