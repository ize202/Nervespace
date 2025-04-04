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
        loadFromLocalStore() // Load local data immediately
        
        // Start background sync
        Task {
            await syncInBackground()
        }
    }
    
    func refresh() async {
        // Load local data immediately
        loadFromLocalStore()
        
        // Then sync in background
        await syncInBackground()
    }
    
    private func syncInBackground() async {
        do {
            await syncManager.syncSupabaseToLocal()
            // Only reload from local store if sync succeeded
            loadFromLocalStore()
        } catch {
            // Just log the error, don't show loading or error states to user
            // since we're operating in local-first mode
            print("[History] Background sync failed: \(error)")
        }
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