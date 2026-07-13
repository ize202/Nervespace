import Foundation
import XCTest
@testable import LocalDataKit

@MainActor
final class LocalActivityStoreTests: XCTestCase {
    func testRecordingIdenticalCompletionTwiceIsIdempotent() throws {
        let persistence = InMemoryRoutineHistoryPersistence()
        let store = try makeStore(persistence: persistence, name: #function)
        let expected = completion(
            id: UUID(uuidString: "bbbbbbbb-1111-1111-1111-111111111111")!,
            minutes: 12,
            at: testDate(2026, 7, 13, 8)
        )

        try store.record(expected)
        try store.record(expected)

        XCTAssertEqual(store.completions, [expected])
        XCTAssertEqual(persistence.snapshot, [expected])
        XCTAssertEqual(store.progress.totalMinutes, 12)
    }

    func testReusingIdentifierWithDifferentDataThrowsConflict() throws {
        let store = try makeStore(
            persistence: InMemoryRoutineHistoryPersistence(),
            name: #function
        )
        let identifier = UUID(uuidString: "bbbbbbbb-2222-2222-2222-222222222222")!
        try store.record(
            completion(id: identifier, minutes: 8, at: testDate(2026, 7, 13, 8))
        )

        XCTAssertThrowsError(
            try store.record(
                completion(id: identifier, minutes: 9, at: testDate(2026, 7, 13, 8))
            )
        ) { error in
            XCTAssertEqual(error as? ActivityStoreError, .completionIDConflict)
        }
    }

    func testDeletingCompletionUpdatesHistoryAndDerivedProgress() throws {
        let firstID = UUID(uuidString: "bbbbbbbb-3333-3333-3333-333333333331")!
        let secondID = UUID(uuidString: "bbbbbbbb-3333-3333-3333-333333333332")!
        let persistence = InMemoryRoutineHistoryPersistence(completions: [
            completion(id: firstID, minutes: 5, at: testDate(2026, 7, 13, 7)),
            completion(id: secondID, minutes: 9, at: testDate(2026, 7, 13, 8)),
        ])
        let store = try makeStore(persistence: persistence, name: #function)

        try store.deleteCompletion(id: firstID)

        XCTAssertEqual(store.completions.map(\.id), [secondID])
        XCTAssertEqual(persistence.snapshot.map(\.id), [secondID])
        XCTAssertEqual(store.progress.minutesToday, 9)
        XCTAssertEqual(store.progress.totalMinutes, 9)
    }

    func testRecordRejectsEmptyRoutineIdentifier() throws {
        let store = try makeStore(
            persistence: InMemoryRoutineHistoryPersistence(),
            name: #function
        )

        XCTAssertThrowsError(
            try store.record(
                completion(
                    id: UUID(uuidString: "bbbbbbbb-4444-4444-4444-444444444444")!,
                    routineID: "   ",
                    minutes: 5,
                    at: testDate(2026, 7, 13, 8)
                )
            )
        ) { error in
            XCTAssertEqual(error as? ActivityStoreError, .invalidRoutineID)
        }
    }

    func testRecordRejectsNonPositiveDuration() throws {
        let store = try makeStore(
            persistence: InMemoryRoutineHistoryPersistence(),
            name: #function
        )

        XCTAssertThrowsError(
            try store.record(
                completion(
                    id: UUID(uuidString: "bbbbbbbb-5555-5555-5555-555555555555")!,
                    minutes: 0,
                    at: testDate(2026, 7, 13, 8)
                )
            )
        ) { error in
            XCTAssertEqual(error as? ActivityStoreError, .invalidDurationMinutes)
        }
    }

    func testDailyGoalMustBePositiveAndPersistsInInjectedDefaults() throws {
        let defaults = isolatedDefaults(named: #function)
        let persistence = InMemoryRoutineHistoryPersistence()
        let store = try LocalActivityStore(
            persistence: persistence,
            defaults: defaults,
            calendar: testCalendar(),
            now: { testDate(2026, 7, 13, 12) }
        )

        XCTAssertThrowsError(try store.setDailyGoal(minutes: 0)) { error in
            XCTAssertEqual(error as? ActivityStoreError, .invalidDailyGoalMinutes)
        }
        try store.setDailyGoal(minutes: 17)
        let reloadedStore = try LocalActivityStore(
            persistence: persistence,
            defaults: defaults,
            calendar: testCalendar(),
            now: { testDate(2026, 7, 13, 12) }
        )

        XCTAssertEqual(store.dailyGoalMinutes, 17)
        XCTAssertEqual(reloadedStore.dailyGoalMinutes, 17)
    }

    private func makeStore(
        persistence: InMemoryRoutineHistoryPersistence,
        name: String
    ) throws -> LocalActivityStore {
        try LocalActivityStore(
            persistence: persistence,
            defaults: isolatedDefaults(named: name),
            calendar: testCalendar(),
            now: { testDate(2026, 7, 13, 12) }
        )
    }
}
