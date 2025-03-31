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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Custom date decoding
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decodeIfPresent(UUID.self, forKey: .userId)
        deviceId = try container.decodeIfPresent(UUID.self, forKey: .deviceId)
        streak = try container.decode(Int.self, forKey: .streak)
        routineCompletions = try container.decode(Int.self, forKey: .routineCompletions)
        totalMinutes = try container.decode(Int.self, forKey: .totalMinutes)
        
        // Handle date decoding with multiple formats
        if let lastActivityString = try container.decodeIfPresent(String.self, forKey: .lastActivity) {
            if let date = dateFormatter.date(from: lastActivityString) {
                lastActivity = date
            } else {
                // Try without fractional seconds
                dateFormatter.formatOptions = [.withInternetDateTime]
                lastActivity = dateFormatter.date(from: lastActivityString)
            }
        } else {
            lastActivity = nil
        }
        
        // Reset formatter options for created_at and updated_at
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        // Handle created_at with fallback to current date
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            if let date = dateFormatter.date(from: createdAtString) {
                createdAt = date
            } else {
                // Try without fractional seconds
                dateFormatter.formatOptions = [.withInternetDateTime]
                createdAt = dateFormatter.date(from: createdAtString) ?? Date()
            }
        } else {
            createdAt = Date()
        }
        
        // Handle updated_at with fallback to current date
        if let updatedAtString = try container.decodeIfPresent(String.self, forKey: .updatedAt) {
            if let date = dateFormatter.date(from: updatedAtString) {
                updatedAt = date
            } else {
                // Try without fractional seconds
                dateFormatter.formatOptions = [.withInternetDateTime]
                updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
            }
        } else {
            updatedAt = Date()
        }
    }
} 