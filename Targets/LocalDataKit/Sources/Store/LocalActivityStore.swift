import Combine
import Foundation

public enum ActivityStoreError: Error, Equatable, Sendable {
    case completionIDConflict
    case invalidRoutineID
    case invalidDurationMinutes
    case invalidDailyGoalMinutes
}

@MainActor
public final class LocalActivityStore: ObservableObject {
    @Published public private(set) var completions: [RoutineCompletion]
    @Published public private(set) var dailyGoalMinutes: Int

    private static let dailyGoalKey = "dailyGoal"
    private static let defaultDailyGoalMinutes = 5
    private static let rolloverHour = 4

    private let persistence: any RoutineHistoryPersistence
    private let defaults: UserDefaults
    private let calculator: ProgressCalculator
    private let now: @Sendable () -> Date

    public init(
        persistence: any RoutineHistoryPersistence,
        defaults: UserDefaults,
        calendar: Calendar,
        now: @escaping @Sendable () -> Date
    ) throws {
        let loadedCompletions = try persistence.load()
        try Self.validate(loadedCompletions)

        let persistedGoal = defaults.object(forKey: Self.dailyGoalKey)
        let dailyGoalMinutes: Int
        if persistedGoal == nil {
            dailyGoalMinutes = Self.defaultDailyGoalMinutes
        } else {
            let value = defaults.integer(forKey: Self.dailyGoalKey)
            guard value > 0 else {
                throw ActivityStoreError.invalidDailyGoalMinutes
            }
            dailyGoalMinutes = value
        }

        self.persistence = persistence
        self.defaults = defaults
        self.calculator = ProgressCalculator(
            calendar: calendar,
            rolloverHour: Self.rolloverHour
        )
        self.now = now
        self.completions = loadedCompletions
        self.dailyGoalMinutes = dailyGoalMinutes
    }

    @discardableResult
    public func record(_ completion: RoutineCompletion) throws -> RoutineCompletion {
        try Self.validate(completion)

        if let existing = completions.first(where: { $0.id == completion.id }) {
            guard existing == completion else {
                throw ActivityStoreError.completionIDConflict
            }
            return existing
        }

        let updatedCompletions = completions + [completion]
        try persistence.save(updatedCompletions)
        completions = updatedCompletions
        return completion
    }

    public func deleteCompletion(id: UUID) throws {
        let updatedCompletions = completions.filter { $0.id != id }
        guard updatedCompletions.count != completions.count else {
            return
        }

        try persistence.save(updatedCompletions)
        completions = updatedCompletions
    }

    public func setDailyGoal(minutes: Int) throws {
        guard minutes > 0 else {
            throw ActivityStoreError.invalidDailyGoalMinutes
        }
        guard minutes != dailyGoalMinutes else {
            return
        }

        defaults.set(minutes, forKey: Self.dailyGoalKey)
        dailyGoalMinutes = minutes
    }

    public var progress: ProgressSummary {
        calculator.summary(
            completions: completions,
            now: now(),
            dailyGoalMinutes: dailyGoalMinutes
        )
    }

    private static func validate(_ completions: [RoutineCompletion]) throws {
        var completionsByID: [UUID: RoutineCompletion] = [:]
        for completion in completions {
            try validate(completion)
            if let existing = completionsByID[completion.id], existing != completion {
                throw ActivityStoreError.completionIDConflict
            }
            completionsByID[completion.id] = completion
        }
    }

    private static func validate(_ completion: RoutineCompletion) throws {
        guard !completion.routineID.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else {
            throw ActivityStoreError.invalidRoutineID
        }
        guard completion.durationMinutes > 0 else {
            throw ActivityStoreError.invalidDurationMinutes
        }
    }
}
