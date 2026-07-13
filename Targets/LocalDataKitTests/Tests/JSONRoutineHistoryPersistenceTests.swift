import Foundation
import XCTest
@testable import LocalDataKit

final class JSONRoutineHistoryPersistenceTests: XCTestCase {
    func testSaveAndLoadPreserveUUIDAndDate() throws {
        let directory = try temporaryTestDirectory(named: #function)
        defer { try? FileManager.default.removeItem(at: directory) }
        let fileURL = directory.appendingPathComponent("history.json")
        let expected = completion(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            minutes: 9,
            at: testDate(2026, 7, 12, 18, 45)
        )
        let persistence = JSONRoutineHistoryPersistence(
            fileURL: fileURL,
            fileManager: .default
        )

        try persistence.save([expected])
        let loaded = try persistence.load()

        XCTAssertEqual(loaded, [expected])
    }

    func testLoadDecodesNumericAndISO8601LegacyDatesAndFiltersTombstones() throws {
        let directory = try temporaryTestDirectory(named: #function)
        defer { try? FileManager.default.removeItem(at: directory) }
        let fileURL = directory.appendingPathComponent("history.json")
        let numericDate = testDate(2026, 7, 10, 9, 30).timeIntervalSinceReferenceDate
        let payload = """
        [
          {
            "id": "33333333-3333-3333-3333-333333333333",
            "user_id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
            "routine_id": "morning_boost",
            "duration_minutes": 8,
            "completed_at": \(numericDate),
            "deleted_at": null,
            "sync_status": "synced"
          },
          {
            "id": "44444444-4444-4444-4444-444444444444",
            "user_id": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
            "routine_id": "evening_calm",
            "duration_minutes": 11,
            "completed_at": "2026-07-11T19:15:00Z",
            "sync_status": "pending"
          },
          {
            "id": "55555555-5555-5555-5555-555555555555",
            "user_id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
            "routine_id": "deleted_routine",
            "duration_minutes": 20,
            "completed_at": "2026-07-12T12:00:00Z",
            "deleted_at": "2026-07-12T12:05:00Z",
            "sync_status": "synced"
          }
        ]
        """
        try Data(payload.utf8).write(to: fileURL)
        let persistence = JSONRoutineHistoryPersistence(
            fileURL: fileURL,
            fileManager: .default
        )

        let loaded = try persistence.load()

        XCTAssertEqual(loaded.map(\.id), [
            UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
        ])
        XCTAssertEqual(loaded[0].completedAt, testDate(2026, 7, 10, 9, 30))
        XCTAssertEqual(loaded[1].completedAt, testDate(2026, 7, 11, 19, 15))
        XCTAssertFalse(loaded.contains { $0.routineID == "deleted_routine" })
    }

    func testSaveCreatesMissingParentDirectory() throws {
        let directory = try temporaryTestDirectory(named: #function)
        defer { try? FileManager.default.removeItem(at: directory) }
        let parentURL = directory.appendingPathComponent("Application Support/Nervespace")
        let fileURL = parentURL.appendingPathComponent("routine_completions.json")
        let persistence = JSONRoutineHistoryPersistence(
            fileURL: fileURL,
            fileManager: .default
        )

        try persistence.save([
            completion(
                id: UUID(uuidString: "66666666-6666-6666-6666-666666666666")!,
                minutes: 5,
                at: testDate(2026, 7, 13, 6)
            )
        ])

        XCTAssertTrue(FileManager.default.fileExists(atPath: parentURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
    }

    func testSaveProducesDeterministicHistoryOrdering() throws {
        let directory = try temporaryTestDirectory(named: #function)
        defer { try? FileManager.default.removeItem(at: directory) }
        let fileURL = directory.appendingPathComponent("history.json")
        let older = completion(
            id: UUID(uuidString: "66666666-6666-6666-6666-666666666661")!,
            minutes: 5,
            at: testDate(2026, 7, 12, 6)
        )
        let newer = completion(
            id: UUID(uuidString: "66666666-6666-6666-6666-666666666662")!,
            minutes: 8,
            at: testDate(2026, 7, 13, 6)
        )
        let persistence = JSONRoutineHistoryPersistence(fileURL: fileURL)

        try persistence.save([older, newer])
        let firstEncoding = try Data(contentsOf: fileURL)
        try persistence.save([newer, older])

        XCTAssertEqual(try Data(contentsOf: fileURL), firstEncoding)
        XCTAssertEqual(try persistence.load().map(\.id), [newer.id, older.id])
    }

    func testCorruptExistingFileThrowsRatherThanReturningEmptyHistory() throws {
        let directory = try temporaryTestDirectory(named: #function)
        defer { try? FileManager.default.removeItem(at: directory) }
        let fileURL = directory.appendingPathComponent("history.json")
        try Data("not-json".utf8).write(to: fileURL)
        let persistence = JSONRoutineHistoryPersistence(fileURL: fileURL)

        XCTAssertThrowsError(try persistence.load())
        XCTAssertEqual(try Data(contentsOf: fileURL), Data("not-json".utf8))
    }
}
