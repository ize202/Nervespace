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
            return try Self.decoder().decode([RoutineCompletion].self, from: data)
        } catch {
            return try Self.legacyDecoder().decode([LegacyRoutineCompletion].self, from: data)
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
        let data = try Self.encoder().encode(sortedCompletions)
        try data.write(to: fileURL, options: .atomic)
    }

    private static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    private static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private static func legacyDecoder() -> JSONDecoder {
        JSONDecoder()
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
        completedAt = try container.decode(LegacyDate.self, forKey: .completedAt).value
        deletedAt = try container.decodeIfPresent(LegacyDate.self, forKey: .deletedAt)?.value
    }
}

private struct LegacyDate: Decodable {
    let value: Date

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let interval = try? container.decode(Double.self) {
            value = Date(timeIntervalSinceReferenceDate: interval)
            return
        }

        let value = try container.decode(String.self)
        guard let date = ISO8601DateFormatter().date(from: value) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected an ISO-8601 date or reference-date interval"
            )
        }
        self.value = date
    }
}
