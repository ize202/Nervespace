import Foundation

public struct LegacyRoutineHistoryMigrator {
    public let sourceURL: URL
    public let destinationURL: URL
    public let fileManager: FileManager

    public init(
        sourceURL: URL,
        destinationURL: URL,
        fileManager: FileManager = .default
    ) {
        self.sourceURL = sourceURL
        self.destinationURL = destinationURL
        self.fileManager = fileManager
    }

    public func migrate() throws {
        guard !fileManager.fileExists(atPath: destinationURL.path) else {
            return
        }
        guard fileManager.fileExists(atPath: sourceURL.path) else {
            return
        }

        let completions = try JSONRoutineHistoryPersistence(
            fileURL: sourceURL,
            fileManager: fileManager
        ).load()
        let temporaryURL = destinationURL
            .deletingLastPathComponent()
            .appendingPathComponent(".\(destinationURL.lastPathComponent).\(UUID().uuidString).migration")
        defer { try? fileManager.removeItem(at: temporaryURL) }

        try JSONRoutineHistoryPersistence(
            fileURL: temporaryURL,
            fileManager: fileManager
        ).save(completions)

        guard !fileManager.fileExists(atPath: destinationURL.path) else {
            return
        }

        do {
            try fileManager.moveItem(at: temporaryURL, to: destinationURL)
        } catch {
            if fileManager.fileExists(atPath: destinationURL.path) {
                return
            }
            throw error
        }
    }
}
