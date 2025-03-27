import Foundation

public struct Plan: Identifiable, Codable, Hashable {
    public let id: UUID
    public let name: String
    public let description: String
    public let thumbnailURL: URL?
    public let isPremium: Bool
    public let duration: String // e.g. "7 DAY SERIES"
    public let routines: [Routine] // Ordered array of routines, one for each day
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        thumbnailURL: URL? = nil,
        isPremium: Bool,
        duration: String,
        routines: [Routine],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.isPremium = isPremium
        self.duration = duration
        self.routines = routines
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case thumbnailURL = "thumbnail_url"
        case isPremium = "is_premium"
        case duration
        case routines
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 