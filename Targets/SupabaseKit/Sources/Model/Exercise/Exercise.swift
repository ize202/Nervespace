import Foundation

public struct Exercise: Identifiable, Codable, Hashable {
    public let id: UUID
    public let name: String
    public let description: String?
    public let instructions: String?
    public let modifications: String?
    public let benefits: String?
    public let categories: [ExerciseCategory]
    public let positions: [ExercisePosition]
    public let areas: [ExerciseArea]
    public let thumbnailURL: URL?
    public let animationURL: URL?
    public let videoURL: URL?
    public let previewURL: URL?
    public let duration: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String? = nil,
        instructions: String? = nil,
        modifications: String? = nil,
        benefits: String? = nil,
        categories: [ExerciseCategory],
        positions: [ExercisePosition],
        areas: [ExerciseArea],
        thumbnailURL: URL? = nil,
        animationURL: URL? = nil,
        videoURL: URL? = nil,
        previewURL: URL? = nil,
        duration: Int,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.instructions = instructions
        self.modifications = modifications
        self.benefits = benefits
        self.categories = categories
        self.positions = positions
        self.areas = areas
        self.thumbnailURL = thumbnailURL
        self.animationURL = animationURL
        self.videoURL = videoURL
        self.previewURL = previewURL
        self.duration = duration
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case instructions
        case modifications
        case benefits
        case categories
        case positions
        case areas
        case thumbnailURL = "thumbnail_url"
        case animationURL = "animation_url"
        case videoURL = "video_url"
        case previewURL = "preview_url"
        case duration
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
} 