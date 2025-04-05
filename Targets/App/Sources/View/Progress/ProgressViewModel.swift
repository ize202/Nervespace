import SwiftUI
import SharedKit
import SupabaseKit

@MainActor
final class ProgressViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    // MARK: - Private Properties
    private let calendar = Calendar.current
    private let progressStore: LocalProgressStore
    private let syncManager: SupabaseSyncManager
    
    // MARK: - Public Properties
    
    public var streak: Int { progressStore.streak }
    public var dailyMinutes: Int { progressStore.dailyMinutes }
    public var totalMinutes: Int { progressStore.totalMinutes }
    public var lastActivity: Date? { progressStore.lastActivity }
    
    // MARK: - Initialization
    
    init(progressStore: LocalProgressStore, syncManager: SupabaseSyncManager) {
        self.progressStore = progressStore
        self.syncManager = syncManager
        
        // Start background sync
        Task {
            await syncInBackground()
        }
    }
    
    // MARK: - Public Methods
    
    /// Refreshes data from local store and syncs with Supabase in background
    func refresh() async {
        isLoading = true
        
        // Force a sync from Supabase to ensure we get the latest data
        // especially after server-side deletions
        do {
            print("[Progress] Forcing refresh from server...")
            
            if let userId = syncManager.db.currentUser?.id {
                do {
                    // Directly fetch server data
                    let serverProgress = try await syncManager.db.userService.fetchProgress(userId: userId)
                    
                    // Update the local store with server data
                    progressStore.updateProgress(
                        streak: serverProgress.streak,
                        dailyMinutes: serverProgress.dailyMinutes,
                        totalMinutes: serverProgress.totalMinutes,
                        lastActivity: serverProgress.lastActivity
                    )
                    
                    print("[Progress] Updated with server data: daily=\(serverProgress.dailyMinutes), total=\(serverProgress.totalMinutes)")
                    error = nil
                } catch {
                    print("[Progress] Could not fetch server data: \(error). Will use local data.")
                    // Not setting error to keep UI clean - we'll just use local data
                }
            }
        } catch {
            print("[Progress] Server refresh failed: \(error)")
        }
        
        isLoading = false
    }
    
    public func updateProgress(minutes: Int) async {
        guard minutes > 0 else { return }
        
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        // Calculate new values
        var newDailyMinutes = minutes
        var newStreak = 1
        
        if let lastActivity = lastActivity {
            let lastActivityDay = calendar.startOfDay(for: lastActivity)
            
            if lastActivityDay == startOfToday {
                // More activity today
                newDailyMinutes = dailyMinutes + minutes
            } else if calendar.isDate(lastActivityDay, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: startOfToday)!) {
                // Activity on consecutive day
                newStreak = streak + 1
            }
        }
        
        let newTotalMinutes = totalMinutes + minutes
        
        // Update local store immediately
        progressStore.updateProgress(
            streak: newStreak,
            dailyMinutes: newDailyMinutes,
            totalMinutes: newTotalMinutes,
            lastActivity: now
        )
        
        // Sync to Supabase in background
        Task {
            await syncManager.syncLocalToSupabase()
        }
    }
    
    // Test method for development only
    #if DEBUG
    func testRecordFiveMinutes() async {
        await updateProgress(minutes: 5)
    }
    #endif
    
    // MARK: - Private Methods
    
    private func syncInBackground() async {
        do {
            await syncManager.syncSupabaseToLocal()
        } catch {
            // Just log the error, don't show loading or error states to user
            // since we're operating in local-first mode
            print("[Progress] Background sync failed: \(error)")
        }
    }
} 