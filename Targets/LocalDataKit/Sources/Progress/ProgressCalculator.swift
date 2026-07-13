import Foundation

public struct ProgressCalculator: Sendable {
    public let calendar: Calendar
    public let rolloverHour: Int

    public init(calendar: Calendar, rolloverHour: Int) {
        precondition((0...23).contains(rolloverHour), "Rollover hour must be between 0 and 23")
        self.calendar = calendar
        self.rolloverHour = rolloverHour
    }

    public func activityDay(containing date: Date) -> Date {
        guard let shiftedDate = calendar.date(
            byAdding: .hour,
            value: -rolloverHour,
            to: date
        ) else {
            preconditionFailure("The configured calendar could not calculate an activity day")
        }
        return calendar.startOfDay(for: shiftedDate)
    }

    public func summary(
        completions: [RoutineCompletion],
        now: Date,
        dailyGoalMinutes: Int
    ) -> ProgressSummary {
        let currentActivityDay = activityDay(containing: now)
        let minutesToday = completions
            .filter { activityDay(containing: $0.completedAt) == currentActivityDay }
            .reduce(0) { $0 + $1.durationMinutes }
        let totalMinutes = completions.reduce(0) { $0 + $1.durationMinutes }
        let activityDays = Set(completions.map { activityDay(containing: $0.completedAt) })

        return ProgressSummary(
            minutesToday: minutesToday,
            totalMinutes: totalMinutes,
            currentStreak: currentStreak(
                activityDays: activityDays,
                currentActivityDay: currentActivityDay
            ),
            dailyGoalMinutes: dailyGoalMinutes,
            lastActivity: completions.map(\.completedAt).max()
        )
    }

    private func currentStreak(
        activityDays: Set<Date>,
        currentActivityDay: Date
    ) -> Int {
        guard !activityDays.isEmpty else {
            return 0
        }

        let previousActivityDay = day(before: currentActivityDay)
        var day: Date
        if activityDays.contains(currentActivityDay) {
            day = currentActivityDay
        } else if activityDays.contains(previousActivityDay) {
            day = previousActivityDay
        } else {
            return 0
        }

        var streak = 0
        while activityDays.contains(day) {
            streak += 1
            day = self.day(before: day)
        }
        return streak
    }

    private func day(before date: Date) -> Date {
        guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else {
            preconditionFailure("The configured calendar could not calculate the previous day")
        }
        return previousDay
    }
}
