import Foundation

public struct Routine: Identifiable, Codable, Hashable {
    public let id: UUID
    public let name: String
    public let description: String?
    public let thumbnailURL: URL?
    public let isPremium: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID,
        name: String,
        description: String?,
        thumbnailURL: URL?,
        isPremium: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.isPremium = isPremium
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case thumbnailURL = "thumbnail_url"
        case isPremium = "is_premium"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 