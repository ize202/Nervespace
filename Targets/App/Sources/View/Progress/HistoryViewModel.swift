import SwiftUI
import SharedKit
import SupabaseKit

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var completedRoutines: [CompletedRoutine] = []
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    private let completionStore: RoutineCompletionStore
    private let syncManager: SupabaseSyncManager
    
    init(completionStore: RoutineCompletionStore, syncManager: SupabaseSyncManager) {
        self.completionStore = completionStore
        self.syncManager = syncManager
        
        // Load local data immediately - this is fast and doesn't require network
        loadFromLocalStore()
    }
    
    func refresh() async {
        isLoading = true
        
        if let userId = syncManager.db.currentUser?.id {
            do {
                print("[History] Forcing refresh from server...")
                
                // Directly fetch completions from the server
                let serverCompletions = try await syncManager.db.userService.getRecentCompletions(userId: userId, days: 30)
                
                // Update the local store with server data
                completionStore.updateCompletions(serverCompletions)
                
                // Reload from local store to update the UI
                loadFromLocalStore()
                
                print("[History] Updated with \(serverCompletions.count) completions from server")
                error = nil
            } catch {
                print("[History] Server refresh failed: \(error)")
                
                // Still load from local store as fallback
                loadFromLocalStore()
                
                // For history view, we don't show an error since no completions is a valid state
                // Just use whatever we have locally
            }
        } else {
            // No user ID - load from local store only
            loadFromLocalStore()
        }
        
        isLoading = false
    }
    
    /// Deletes a completion both locally and in Supabase
    func deleteCompletion(id: UUID) async {
        // First, remove from local completed routines for immediate UI update
        completedRoutines.removeAll { $0.id == id }
        
        // Then delete through sync manager (handles both local store and Supabase)
        await syncManager.deleteCompletion(id: id)
        
        // Reload the local store to ensure UI is in sync with store
        loadFromLocalStore()
    }
    
    private func loadFromLocalStore() {
        let recentCompletions = completionStore.getRecentCompletions(days: 30)
        completedRoutines = recentCompletions.map { CompletedRoutine(completion: $0) }
    }
    
    func groupedRoutines() -> [(String, [CompletedRoutine])] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        
        let grouped = Dictionary(grouping: completedRoutines) { routine in
            if calendar.isDateInToday(routine.date) {
                return "Today"
            } else if calendar.isDateInYesterday(routine.date) {
                return "Yesterday"
            } else {
                return dateFormatter.string(from: routine.date)
            }
        }
        
        return grouped.sorted { lhs, rhs in
            let lhsDate = completedRoutines.first { routine in
                if calendar.isDateInToday(routine.date) {
                    return lhs.key == "Today"
                } else if calendar.isDateInYesterday(routine.date) {
                    return lhs.key == "Yesterday"
                } else {
                    return dateFormatter.string(from: routine.date) == lhs.key
                }
            }?.date ?? Date.distantPast
            
            let rhsDate = completedRoutines.first { routine in
                if calendar.isDateInToday(routine.date) {
                    return rhs.key == "Today"
                } else if calendar.isDateInYesterday(routine.date) {
                    return rhs.key == "Yesterday"
                } else {
                    return dateFormatter.string(from: routine.date) == rhs.key
                }
            }?.date ?? Date.distantPast
            
            return lhsDate > rhsDate
        }
    }
} 