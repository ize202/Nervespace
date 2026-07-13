import Foundation
import os
@testable import LocalDataKit

func testCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "en_US_POSIX")
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
}

func testDate(
    _ year: Int,
    _ month: Int,
    _ day: Int,
    _ hour: Int = 0,
    _ minute: Int = 0,
    _ second: Int = 0
) -> Date {
    let components = DateComponents(
        calendar: testCalendar(),
        timeZone: TimeZone(secondsFromGMT: 0),
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second
    )
    return testCalendar().date(from: components)!
}

func temporaryTestDirectory(named name: String) throws -> URL {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("Nervespace-\(name)-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    return directory
}

func isolatedDefaults(named name: String) -> UserDefaults {
    let suiteName = "com.slips.nervespace.tests.\(name).\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    return defaults
}

func completion(
    id: UUID,
    routineID: String = "morning_boost",
    minutes: Int,
    at date: Date
) -> RoutineCompletion {
    RoutineCompletion(
        id: id,
        routineID: routineID,
        durationMinutes: minutes,
        completedAt: date
    )
}

final class InMemoryRoutineHistoryPersistence: RoutineHistoryPersistence {
    private let storedCompletions: OSAllocatedUnfairLock<[RoutineCompletion]>

    init(completions: [RoutineCompletion] = []) {
        storedCompletions = OSAllocatedUnfairLock(initialState: completions)
    }

    func load() throws -> [RoutineCompletion] {
        storedCompletions.withLock { $0 }
    }

    func save(_ completions: [RoutineCompletion]) throws {
        storedCompletions.withLock { $0 = completions }
    }

    var snapshot: [RoutineCompletion] {
        storedCompletions.withLock { $0 }
    }
}

enum TestPersistenceError: Error {
    case rejectedWrite
}

final class RejectingRoutineHistoryPersistence: RoutineHistoryPersistence {
    private let completions: [RoutineCompletion]

    init(completions: [RoutineCompletion] = []) {
        self.completions = completions
    }

    func load() throws -> [RoutineCompletion] {
        completions
    }

    func save(_ completions: [RoutineCompletion]) throws {
        throw TestPersistenceError.rejectedWrite
    }
}
