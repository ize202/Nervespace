import Foundation
import XCTest
@testable import LocalDataKit

final class LegacyRoutineHistoryMigratorTests: XCTestCase {
    func testMigrationCopiesLegacyHistoryWhenDestinationIsAbsent() throws {
        let directory = try temporaryTestDirectory(named: #function)
        defer { try? FileManager.default.removeItem(at: directory) }
        let sourceURL = directory.appendingPathComponent("Documents/routine_completions.json")
        let destinationURL = directory.appendingPathComponent(
            "Application Support/Nervespace/routine_completions.json"
        )
        try FileManager.default.createDirectory(
            at: sourceURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let payload = """
        [{
          "id": "77777777-7777-7777-7777-777777777777",
          "user_id": "dddddddd-dddd-dddd-dddd-dddddddddddd",
          "routine_id": "morning_boost",
          "duration_minutes": 10,
          "completed_at": "2026-07-09T07:30:00Z",
          "deleted_at": null,
          "sync_status": "synced"
        }]
        """
        try Data(payload.utf8).write(to: sourceURL)
        let migrator = LegacyRoutineHistoryMigrator(
            sourceURL: sourceURL,
            destinationURL: destinationURL,
            fileManager: .default
        )

        try migrator.migrate()

        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path))
        let persistence = JSONRoutineHistoryPersistence(
            fileURL: destinationURL,
            fileManager: .default
        )
        XCTAssertEqual(try persistence.load(), [
            completion(
                id: UUID(uuidString: "77777777-7777-7777-7777-777777777777")!,
                minutes: 10,
                at: testDate(2026, 7, 9, 7, 30)
            )
        ])
    }

    func testMigrationNeverOverwritesExistingDestination() throws {
        let directory = try temporaryTestDirectory(named: #function)
        defer { try? FileManager.default.removeItem(at: directory) }
        let sourceURL = directory.appendingPathComponent("Documents/routine_completions.json")
        let destinationURL = directory.appendingPathComponent(
            "Application Support/Nervespace/routine_completions.json"
        )
        try FileManager.default.createDirectory(
            at: sourceURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: destinationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data("[]".utf8).write(to: sourceURL)
        let existingData = Data("existing destination".utf8)
        try existingData.write(to: destinationURL)
        let migrator = LegacyRoutineHistoryMigrator(
            sourceURL: sourceURL,
            destinationURL: destinationURL,
            fileManager: .default
        )

        try migrator.migrate()

        XCTAssertEqual(try Data(contentsOf: destinationURL), existingData)
    }

    func testCorruptLegacyFileThrowsWithoutCreatingDestination() throws {
        let directory = try temporaryTestDirectory(named: #function)
        defer { try? FileManager.default.removeItem(at: directory) }
        let sourceURL = directory.appendingPathComponent("Documents/routine_completions.json")
        let destinationURL = directory.appendingPathComponent(
            "Application Support/Nervespace/routine_completions.json"
        )
        try FileManager.default.createDirectory(
            at: sourceURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data("not-json".utf8).write(to: sourceURL)
        let migrator = LegacyRoutineHistoryMigrator(
            sourceURL: sourceURL,
            destinationURL: destinationURL,
            fileManager: .default
        )

        XCTAssertThrowsError(try migrator.migrate())
        XCTAssertFalse(FileManager.default.fileExists(atPath: destinationURL.path))
    }
}
