import Foundation

public struct PlanRoutine: Identifiable, Hashable {
    public let id: String
    public let routine: Routine
    public let day: Int
    public let sequenceOrder: Int
    
    public init(routine: Routine, day: Int, sequenceOrder: Int = 1) {
        self.id = UUID().uuidString
        self.routine = routine
        self.day = day
        self.sequenceOrder = sequenceOrder
    }
}

public struct Plan: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let isPremium: Bool
    public let routines: [PlanRoutine]
    
    public init(
        name: String,
        description: String,
        isPremium: Bool = false,
        routines: [PlanRoutine]
    ) {
        self.id = name.lowercased().replacingOccurrences(of: " ", with: "_")
        self.name = name
        self.description = description
        self.isPremium = isPremium
        self.routines = routines
    }
    
    public var thumbnailName: String {
        "plan_\(id)"
    }
    
    public var totalDays: Int {
        routines.map(\.day).max() ?? 0
    }
} 