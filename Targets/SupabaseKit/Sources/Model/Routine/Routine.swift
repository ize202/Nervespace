import Foundation

public struct Routine: Identifiable, Codable, Hashable {
    public let id: UUID
    public let name: String
    public let description: String?
    public let bigThumbnailURL: URL?
    public let thumbnailURL: URL?
    public let isPremium: Bool
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        bigThumbnailURL: URL? = nil,
        thumbnailURL: URL? = nil,
        isPremium: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.bigThumbnailURL = bigThumbnailURL
        self.thumbnailURL = thumbnailURL
        self.isPremium = isPremium
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case bigThumbnailURL = "big_thumbnail_url"
        case thumbnailURL = "thumbnail_url"
        case isPremium = "is_premium"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 