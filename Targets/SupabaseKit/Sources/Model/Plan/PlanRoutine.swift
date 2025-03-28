import Foundation

public struct PlanRoutine: Identifiable, Codable, Hashable {
    public let id: UUID
    public let planId: UUID
    public let routineId: UUID
    public let day: Int
    
    public init(
        id: UUID = UUID(),
        planId: UUID,
        routineId: UUID,
        day: Int
    ) {
        self.id = id
        self.planId = planId
        self.routineId = routineId
        self.day = day
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case planId = "plan_id"
        case routineId = "routine_id"
        case day
    }
} 