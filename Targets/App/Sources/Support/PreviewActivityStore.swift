import Foundation
import LocalDataKit

@MainActor
func makePreviewActivityStore() -> LocalActivityStore {
    let identifier = "com.slips.nervespace.preview"
    let defaults = UserDefaults(suiteName: identifier)!
    let fileURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("\(identifier).routine-completions.json")

    return try! LocalActivityStore(
        persistence: JSONRoutineHistoryPersistence(fileURL: fileURL),
        defaults: defaults,
        calendar: .current,
        now: { Date() }
    )
}
