import Foundation
import XCTest
@testable import LocalDataKit

final class ProgressCalculatorTests: XCTestCase {
    func testCompletionBeforeRolloverBelongsToPreviousActivityDay() {
        let calculator = ProgressCalculator(calendar: testCalendar(), rolloverHour: 4)

        let activityDay = calculator.activityDay(containing: testDate(2026, 7, 13, 3, 30))

        XCTAssertEqual(activityDay, testDate(2026, 7, 12))
    }

    func testCompletionAtRolloverBelongsToNewActivityDay() {
        let calculator = ProgressCalculator(calendar: testCalendar(), rolloverHour: 4)

        let activityDay = calculator.activityDay(containing: testDate(2026, 7, 13, 4))

        XCTAssertEqual(activityDay, testDate(2026, 7, 13))
    }

    func testConsecutiveActivityDaysProduceCurrentStreak() {
        let calculator = ProgressCalculator(calendar: testCalendar(), rolloverHour: 4)
        let completions = [
            completion(
                id: UUID(uuidString: "88888888-8888-8888-8888-888888888881")!,
                minutes: 5,
                at: testDate(2026, 7, 11, 8)
            ),
            completion(
                id: UUID(uuidString: "88888888-8888-8888-8888-888888888882")!,
                minutes: 7,
                at: testDate(2026, 7, 12, 8)
            ),
            completion(
                id: UUID(uuidString: "88888888-8888-8888-8888-888888888883")!,
                minutes: 9,
                at: testDate(2026, 7, 13, 8)
            ),
        ]

        let summary = calculator.summary(
            completions: completions,
            now: testDate(2026, 7, 13, 12),
            dailyGoalMinutes: 10
        )

        XCTAssertEqual(summary.currentStreak, 3)
        XCTAssertEqual(summary.minutesToday, 9)
        XCTAssertEqual(summary.totalMinutes, 21)
        XCTAssertEqual(summary.lastActivity, testDate(2026, 7, 13, 8))
    }

    func testMissedActivityDayResetsCurrentStreak() {
        let calculator = ProgressCalculator(calendar: testCalendar(), rolloverHour: 4)
        let completions = [
            completion(
                id: UUID(uuidString: "99999999-9999-9999-9999-999999999991")!,
                minutes: 5,
                at: testDate(2026, 7, 11, 8)
            ),
            completion(
                id: UUID(uuidString: "99999999-9999-9999-9999-999999999993")!,
                minutes: 9,
                at: testDate(2026, 7, 13, 8)
            ),
        ]

        let summary = calculator.summary(
            completions: completions,
            now: testDate(2026, 7, 13, 12),
            dailyGoalMinutes: 10
        )

        XCTAssertEqual(summary.currentStreak, 1)
    }
}
