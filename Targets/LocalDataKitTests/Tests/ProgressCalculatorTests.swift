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

    func testSpringForwardUsesLocalFourAMBoundary() {
        let calendar = torontoTestCalendar()
        let calculator = ProgressCalculator(calendar: calendar, rolloverHour: 4)
        let beforeBoundary = testISODate("2026-03-08T03:59:00-04:00")
        let boundary = testISODate("2026-03-08T04:00:00-04:00")
        let completions = [
            completion(
                id: UUID(uuidString: "88888888-8888-8888-8888-888888888871")!,
                minutes: 5,
                at: beforeBoundary
            ),
            completion(
                id: UUID(uuidString: "88888888-8888-8888-8888-888888888872")!,
                minutes: 7,
                at: boundary
            ),
        ]

        XCTAssertEqual(
            calculator.activityDay(containing: beforeBoundary),
            testLocalDate(2026, 3, 7, calendar: calendar)
        )
        XCTAssertEqual(
            calculator.activityDay(containing: boundary),
            testLocalDate(2026, 3, 8, calendar: calendar)
        )
        XCTAssertEqual(
            calculator.summary(
                completions: completions,
                now: testISODate("2026-03-08T04:30:00-04:00"),
                dailyGoalMinutes: 10
            ).minutesToday,
            7
        )
    }

    func testFallBackRepeatedHoursRemainBeforeLocalFourAMBoundary() {
        let calendar = torontoTestCalendar()
        let calculator = ProgressCalculator(calendar: calendar, rolloverHour: 4)
        let firstRepeatedHour = testISODate("2026-11-01T01:30:00-04:00")
        let secondRepeatedHour = testISODate("2026-11-01T01:30:00-05:00")
        let boundary = testISODate("2026-11-01T04:00:00-05:00")
        let previousActivityDay = testLocalDate(2026, 10, 31, calendar: calendar)

        XCTAssertEqual(
            calculator.activityDay(containing: firstRepeatedHour),
            previousActivityDay
        )
        XCTAssertEqual(
            calculator.activityDay(containing: secondRepeatedHour),
            previousActivityDay
        )
        XCTAssertEqual(
            calculator.activityDay(containing: boundary),
            testLocalDate(2026, 11, 1, calendar: calendar)
        )
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
