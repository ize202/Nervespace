import Foundation
import SharedKit

class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()
    
    @Published private(set) var bookmarkedRoutineIds: Set<UUID> = []
    private let defaults = UserDefaults.standard
    private let bookmarksKey = "bookmarked_routines"
    
    private init() {
        // Load saved bookmarks
        if let savedIds = defaults.array(forKey: bookmarksKey) as? [String] {
            bookmarkedRoutineIds = Set(savedIds.compactMap { UUID(uuidString: $0) })
        }
    }
    
    func isBookmarked(_ routine: Routine) -> Bool {
        bookmarkedRoutineIds.contains(routine.id)
    }
    
    func toggleBookmark(for routine: Routine) {
        if bookmarkedRoutineIds.contains(routine.id) {
            bookmarkedRoutineIds.remove(routine.id)
        } else {
            bookmarkedRoutineIds.insert(routine.id)
        }
        saveBookmarks()
    }
    
    private func saveBookmarks() {
        let stringIds = bookmarkedRoutineIds.map { $0.uuidString }
        defaults.set(stringIds, forKey: bookmarksKey)
    }
    
    func getBookmarkedRoutines() -> [Routine] {
        return RoutineLibrary.routines.filter { bookmarkedRoutineIds.contains($0.id) }
    }
} 