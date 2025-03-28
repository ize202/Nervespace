import Foundation

public struct UserProfile: Identifiable, Codable, Hashable {
    public let id: UUID
    public let appleId: String
    public let email: String?
    public let name: String?
    public let avatarURL: URL?
    public let isPremium: Bool
    public let premiumUntil: Date?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        appleId: String,
        email: String? = nil,
        name: String? = nil,
        avatarURL: URL? = nil,
        isPremium: Bool = false,
        premiumUntil: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.appleId = appleId
        self.email = email
        self.name = name
        self.avatarURL = avatarURL
        self.isPremium = isPremium
        self.premiumUntil = premiumUntil
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case appleId = "apple_id"
        case email
        case name
        case avatarURL = "avatar_url"
        case isPremium = "is_premium"
        case premiumUntil = "premium_until"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 