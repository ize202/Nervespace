import Foundation

public struct Exercise: Identifiable, Codable, Hashable {
    public let id: UUID
    public let name: String
    public let description: String?
    public let instructions: String?
    public let thumbnailURL: URL?
    public let animationURL: URL?
    public let videoURL: URL?
    public let previewURL: URL?
    public let baseDuration: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID,
        name: String,
        description: String?,
        instructions: String?,
        thumbnailURL: URL?,
        animationURL: URL?,
        videoURL: URL?,
        previewURL: URL?,
        baseDuration: Int,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.instructions = instructions
        self.thumbnailURL = thumbnailURL
        self.animationURL = animationURL
        self.videoURL = videoURL
        self.previewURL = previewURL
        self.baseDuration = baseDuration
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case instructions
        case thumbnailURL = "thumbnail_url"
        case animationURL = "animation_url"
        case videoURL = "video_url"
        case previewURL = "preview_url"
        case baseDuration = "base_duration"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 