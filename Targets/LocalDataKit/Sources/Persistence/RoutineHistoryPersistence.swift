public protocol RoutineHistoryPersistence: Sendable {
    func load() throws -> [RoutineCompletion]
    func save(_ completions: [RoutineCompletion]) throws
}
