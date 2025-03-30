import Foundation

public class BookmarkManager: ObservableObject {
    public static let shared = BookmarkManager()
    
    @Published public private(set) var bookmarkedRoutineIds: Set<String> = []
    private let defaults = UserDefaults.standard
    private let bookmarksKey = "bookmarked_routines"
    
    private init() {
        // Load saved bookmarks
        if let savedIds = defaults.array(forKey: bookmarksKey) as? [String] {
            bookmarkedRoutineIds = Set(savedIds)
        }
    }
    
    public func isBookmarked(_ routine: Routine) -> Bool {
        bookmarkedRoutineIds.contains(routine.id)
    }
    
    public func toggleBookmark(for routine: Routine) {
        if bookmarkedRoutineIds.contains(routine.id) {
            bookmarkedRoutineIds.remove(routine.id)
        } else {
            bookmarkedRoutineIds.insert(routine.id)
        }
        saveBookmarks()
    }
    
    private func saveBookmarks() {
        let stringIds = Array(bookmarkedRoutineIds)
        defaults.set(stringIds, forKey: bookmarksKey)
    }
    
    public func getBookmarkedRoutines() -> [Routine] {
        return RoutineLibrary.routines.filter { routine in
            bookmarkedRoutineIds.contains(routine.id)
        }
    }
} 