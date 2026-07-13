import Foundation
import LocalDataKit
import os
import SharedKit
import XCTest
@testable import Nervespace

@MainActor
final class SessionCompletionTests: XCTestCase {
    func testCompletedSessionRecordsExactlyOneLocalCompletion() throws {
        let persistence = TestRoutineHistoryPersistence()
        let defaultsName = "com.slips.nervespace.AppTests.\(#function).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: defaultsName)!
        defer { defaults.removePersistentDomain(forName: defaultsName) }
        let completedAt = Date(timeIntervalSinceReferenceDate: 804_427_200)
        let completionID = UUID(uuidString: "dddddddd-1111-1111-1111-111111111111")!
        let store = try LocalActivityStore(
            persistence: persistence,
            defaults: defaults,
            calendar: testCalendar(),
            now: { completedAt }
        )
        let controller = SessionCompletionController(store: store)
        let routine = Routine(
            name: "Test Routine",
            description: "A deterministic test routine.",
            exercises: []
        )

        let completion = try controller.complete(
            routine: routine,
            durationMinutes: 7,
            completedAt: completedAt,
            id: completionID
        )

        XCTAssertEqual(
            completion,
            RoutineCompletion(
                id: completionID,
                routineID: routine.id,
                durationMinutes: 7,
                completedAt: completedAt
            )
        )
        XCTAssertEqual(store.completions, [completion])
        XCTAssertEqual(persistence.snapshot, [completion])
    }

    private func testCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }
}

private final class TestRoutineHistoryPersistence: RoutineHistoryPersistence {
    private let completions = OSAllocatedUnfairLock(initialState: [RoutineCompletion]())

    func load() throws -> [RoutineCompletion] {
        completions.withLock { $0 }
    }

    func save(_ completions: [RoutineCompletion]) throws {
        self.completions.withLock { $0 = completions }
    }

    var snapshot: [RoutineCompletion] {
        completions.withLock { $0 }
    }
}
