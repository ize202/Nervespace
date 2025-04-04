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
    }
    
    // MARK: - Public Methods
    
    /// Refreshes data from local store and optionally syncs with Supabase
    func refresh(syncWithSupabase: Bool = true) async {
        if syncWithSupabase {
            isLoading = true
            await syncManager.syncSupabaseToLocal()
            isLoading = false
        }
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
} 