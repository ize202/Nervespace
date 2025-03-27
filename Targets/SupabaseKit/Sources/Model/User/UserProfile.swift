import Foundation

public struct UserProfile: Identifiable, Codable, Hashable {
    public let id: UUID
    public let email: String
    public let firstName: String?
    public let lastName: String?
    public let avatarURL: URL?
    public let isPremium: Bool
    public let premiumUntil: Date?
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID,
        email: String,
        firstName: String?,
        lastName: String?,
        avatarURL: URL?,
        isPremium: Bool,
        premiumUntil: Date?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.avatarURL = avatarURL
        self.isPremium = isPremium
        self.premiumUntil = premiumUntil
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarURL = "avatar_url"
        case isPremium = "is_premium"
        case premiumUntil = "premium_until"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 