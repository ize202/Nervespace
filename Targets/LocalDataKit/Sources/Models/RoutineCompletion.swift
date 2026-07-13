import Foundation

public struct RoutineCompletion: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public let routineID: String
    public let durationMinutes: Int
    public let completedAt: Date

    public init(
        id: UUID,
        routineID: String,
        durationMinutes: Int,
        completedAt: Date
    ) {
        self.id = id
        self.routineID = routineID
        self.durationMinutes = durationMinutes
        self.completedAt = completedAt
    }
}
