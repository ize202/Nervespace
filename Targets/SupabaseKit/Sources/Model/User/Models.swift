import Foundation

public enum Model {
    public struct UserProfile: Identifiable, Codable, Hashable {
        public let id: UUID
        public let appleId: String?
        public let email: String?
        public let name: String?
        public let avatarUrl: String?
        public let createdAt: Date
        public let updatedAt: Date
        
        public init(
            id: UUID = UUID(),
            appleId: String? = nil,
            email: String? = nil,
            name: String? = nil,
            avatarUrl: String? = nil,
            createdAt: Date = Date(),
            updatedAt: Date = Date()
        ) {
            self.id = id
            self.appleId = appleId
            self.email = email
            self.name = name
            self.avatarUrl = avatarUrl
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case appleId = "apple_id"
            case email
            case name
            case avatarUrl = "avatar_url"
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
    }

    public struct UserProgress: Identifiable, Codable, Hashable {
        public let id: UUID
        public let userId: UUID
        public let streak: Int
        public let dailyMinutes: Int
        public let totalMinutes: Int
        public let lastActivity: Date?
        public let createdAt: Date
        
        public init(
            id: UUID = UUID(),
            userId: UUID,
            streak: Int = 0,
            dailyMinutes: Int = 0,
            totalMinutes: Int = 0,
            lastActivity: Date? = nil,
            createdAt: Date = Date()
        ) {
            self.id = id
            self.userId = userId
            self.streak = streak
            self.dailyMinutes = dailyMinutes
            self.totalMinutes = totalMinutes
            self.lastActivity = lastActivity
            self.createdAt = createdAt
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case streak
            case dailyMinutes = "daily_minutes"
            case totalMinutes = "total_minutes"
            case lastActivity = "last_activity"
            case createdAt = "created_at"
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Custom date decoding
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            id = try container.decode(UUID.self, forKey: .id)
            userId = try container.decode(UUID.self, forKey: .userId)
            streak = try container.decode(Int.self, forKey: .streak)
            dailyMinutes = try container.decode(Int.self, forKey: .dailyMinutes)
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
            
            // Reset formatter options for created_at
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
        }
    }

    public struct RoutineCompletion: Identifiable, Codable, Hashable {
        public let id: UUID
        public let userId: UUID
        public let routineId: String
        public let completedAt: Date
        public let durationMinutes: Int
        public let deletedAt: Date?
        public let syncStatus: String?
        
        public init(
            id: UUID = UUID(),
            userId: UUID,
            routineId: String,
            completedAt: Date = Date(),
            durationMinutes: Int,
            deletedAt: Date? = nil,
            syncStatus: String = "synced"
        ) {
            self.id = id
            self.userId = userId
            self.routineId = routineId
            self.completedAt = completedAt
            self.durationMinutes = durationMinutes
            self.deletedAt = deletedAt
            self.syncStatus = syncStatus
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case routineId = "routine_id"
            case completedAt = "completed_at"
            case durationMinutes = "duration_minutes"
            case deletedAt = "deleted_at"
            case syncStatus = "sync_status"
        }
    }
} 