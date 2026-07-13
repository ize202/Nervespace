import Foundation

public struct CompletionDay: Equatable, Sendable {
    public let activityDay: Date
    public let completions: [RoutineCompletion]

    public init(activityDay: Date, completions: [RoutineCompletion]) {
        self.activityDay = activityDay
        self.completions = completions
    }
}

public enum CompletionHistory {
    public static func sections(
        from completions: [RoutineCompletion],
        calendar: Calendar,
        rolloverHour: Int
    ) -> [CompletionDay] {
        let calculator = ProgressCalculator(
            calendar: calendar,
            rolloverHour: rolloverHour
        )
        let groupedCompletions = Dictionary(grouping: completions) { completion in
            calculator.activityDay(containing: completion.completedAt)
        }

        return groupedCompletions
            .map { activityDay, completions in
                CompletionDay(
                    activityDay: activityDay,
                    completions: completions.sorted(by: areInHistoryOrder)
                )
            }
            .sorted { $0.activityDay > $1.activityDay }
    }

    private static func areInHistoryOrder(
        _ left: RoutineCompletion,
        _ right: RoutineCompletion
    ) -> Bool {
        if left.completedAt != right.completedAt {
            return left.completedAt > right.completedAt
        }
        return left.id.uuidString < right.id.uuidString
    }
}
