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
        fatalError("History grouping is specified by tests and implemented in Task 3")
    }
}
