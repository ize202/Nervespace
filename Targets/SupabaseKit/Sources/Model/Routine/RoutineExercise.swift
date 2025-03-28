import Foundation

public struct RoutineExercise: Identifiable, Codable, Hashable {
    public let id: UUID
    public let routineId: UUID
    public let exerciseId: UUID
    public let sequenceOrder: Int
    public let duration: Int
    
    public init(
        id: UUID = UUID(),
        routineId: UUID,
        exerciseId: UUID,
        sequenceOrder: Int,
        duration: Int
    ) {
        self.id = id
        self.routineId = routineId
        self.exerciseId = exerciseId
        self.sequenceOrder = sequenceOrder
        self.duration = duration
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case routineId = "routine_id"
        case exerciseId = "exercise_id"
        case sequenceOrder = "sequence_order"
        case duration
    }
} 