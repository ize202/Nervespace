import Foundation

public struct ProgressSummary: Equatable, Sendable {
    public let minutesToday: Int
    public let totalMinutes: Int
    public let currentStreak: Int
    public let dailyGoalMinutes: Int
    public let lastActivity: Date?

    public init(
        minutesToday: Int,
        totalMinutes: Int,
        currentStreak: Int,
        dailyGoalMinutes: Int,
        lastActivity: Date?
    ) {
        self.minutesToday = minutesToday
        self.totalMinutes = totalMinutes
        self.currentStreak = currentStreak
        self.dailyGoalMinutes = dailyGoalMinutes
        self.lastActivity = lastActivity
    }
}
