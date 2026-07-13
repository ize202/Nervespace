import Foundation
import LocalDataKit
import SharedKit

@MainActor
final class SessionCompletionController {
    private let store: LocalActivityStore

    init(store: LocalActivityStore) {
        self.store = store
    }

    @discardableResult
    func complete(
        routine: Routine,
        durationMinutes: Int,
        completedAt: Date,
        id: UUID
    ) throws -> LocalDataKit.RoutineCompletion {
        let completion = LocalDataKit.RoutineCompletion(
            id: id,
            routineID: routine.id,
            durationMinutes: durationMinutes,
            completedAt: completedAt
        )
        return try store.record(completion)
    }
}
