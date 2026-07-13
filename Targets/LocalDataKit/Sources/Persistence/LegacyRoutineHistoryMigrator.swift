import Foundation

public struct LegacyRoutineHistoryMigrator: Sendable {
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
        fatalError("Legacy migration is specified by tests and implemented in Task 3")
    }
}
