import Foundation

public struct PlanRoutine: Identifiable, Codable, Hashable {
    public let id: UUID
    public let planId: UUID
    public let routineId: UUID
    public let day: Int
    public let sequenceOrder: Int
    
    public init(
        id: UUID = UUID(),
        planId: UUID,
        routineId: UUID,
        day: Int,
        sequenceOrder: Int = 1
    ) {
        self.id = id
        self.planId = planId
        self.routineId = routineId
        self.day = day
        self.sequenceOrder = sequenceOrder
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case planId = "plan_id"
        case routineId = "routine_id"
        case day
        case sequenceOrder = "sequence_order"
    }
} 