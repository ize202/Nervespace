import Foundation
import os

public struct JSONRoutineHistoryPersistence: RoutineHistoryPersistence {
    public let fileURL: URL
    private let fileManager: LockedFileManager

    public init(
        fileURL: URL,
        fileManager: FileManager = .default
    ) {
        self.fileURL = fileURL
        self.fileManager = LockedFileManager(fileManager)
    }

    public func load() throws -> [RoutineCompletion] {
        guard fileManager.withLock({ $0.fileExists(atPath: fileURL.path) }) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        do {
            return try JSONDecoder()
                .decode([StoredRoutineCompletion].self, from: data)
                .map(\.completion)
        } catch {
            return try JSONDecoder().decode([LegacyRoutineCompletion].self, from: data)
                .filter { $0.deletedAt == nil }
                .map(\.completion)
        }
    }

    public func save(_ completions: [RoutineCompletion]) throws {
        let parentURL = fileURL.deletingLastPathComponent()
        try fileManager.withLock {
            try $0.createDirectory(
                at: parentURL,
                withIntermediateDirectories: true
            )
        }

        let sortedCompletions = completions.sorted(by: Self.areInDeterministicOrder)
        let storedCompletions = sortedCompletions.map(StoredRoutineCompletion.init)
        let data = try Self.encoder().encode(storedCompletions)
        try data.write(to: fileURL, options: .atomic)
    }

    private static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static func areInDeterministicOrder(
        _ left: RoutineCompletion,
        _ right: RoutineCompletion
    ) -> Bool {
        if left.completedAt != right.completedAt {
            return left.completedAt > right.completedAt
        }
        return left.id.uuidString < right.id.uuidString
    }
}

private struct StoredRoutineCompletion: Codable {
    let id: UUID
    let routineID: String
    let durationMinutes: Int
    let completedAt: StoredDate

    init(_ completion: RoutineCompletion) {
        id = completion.id
        routineID = completion.routineID
        durationMinutes = completion.durationMinutes
        completedAt = StoredDate(completion.completedAt)
    }

    var completion: RoutineCompletion {
        RoutineCompletion(
            id: id,
            routineID: routineID,
            durationMinutes: durationMinutes,
            completedAt: completedAt.value
        )
    }
}

private final class LockedFileManager: Sendable {
    // FileManager is not annotated Sendable by Foundation. Every use of this
    // reference is serialized by the lock below.
    nonisolated(unsafe) private let value: FileManager
    private let lock = OSAllocatedUnfairLock()

    init(_ value: FileManager) {
        self.value = value
    }

    func withLock<Result: Sendable>(
        _ operation: @Sendable (FileManager) throws -> Result
    ) rethrows -> Result {
        try lock.withLock {
            try operation(value)
        }
    }
}

private struct LegacyRoutineCompletion: Decodable {
    let id: UUID
    let routineID: String
    let durationMinutes: Int
    let completedAt: Date
    let deletedAt: Date?

    var completion: RoutineCompletion {
        RoutineCompletion(
            id: id,
            routineID: routineID,
            durationMinutes: durationMinutes,
            completedAt: completedAt
        )
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case routineID = "routine_id"
        case durationMinutes = "duration_minutes"
        case completedAt = "completed_at"
        case deletedAt = "deleted_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        routineID = try container.decode(String.self, forKey: .routineID)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        completedAt = try container.decode(StoredDate.self, forKey: .completedAt).value
        deletedAt = try container.decodeIfPresent(StoredDate.self, forKey: .deletedAt)?.value
    }
}

private struct StoredDate: Codable {
    let value: Date

    init(_ value: Date) {
        self.value = value
    }

    private enum CodingKeys: String, CodingKey {
        case iso8601
        case referenceDateSeconds
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if let exactInterval = try container.decodeIfPresent(
                Double.self,
                forKey: .referenceDateSeconds
            ) {
                value = Date(timeIntervalSinceReferenceDate: exactInterval)
                return
            }
            if let iso8601 = try container.decodeIfPresent(String.self, forKey: .iso8601) {
                value = try Self.parseISO8601(iso8601, codingPath: decoder.codingPath)
                return
            }
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected an exact reference-date interval or ISO-8601 date"
                )
            )
        }

        let container = try decoder.singleValueContainer()
        if let interval = try? container.decode(Double.self) {
            value = Date(timeIntervalSinceReferenceDate: interval)
            return
        }

        let iso8601 = try container.decode(String.self)
        value = try Self.parseISO8601(iso8601, codingPath: decoder.codingPath)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(
            value.timeIntervalSinceReferenceDate,
            forKey: .referenceDateSeconds
        )
        let format = Date.ISO8601FormatStyle(
            includingFractionalSeconds: true,
            timeZone: .gmt
        )
        try container.encode(format.format(value), forKey: .iso8601)
    }

    private static func parseISO8601(
        _ value: String,
        codingPath: [any CodingKey]
    ) throws -> Date {
        let format = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
        do {
            return try format.parse(value)
        } catch {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected an ISO-8601 date or reference-date interval",
                    underlyingError: error
                )
            )
        }
    }
}
