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
    
    @Published private(set) var streak: Int = 0
    @Published private(set) var dailyMinutes: Int = 0
    @Published private(set) var totalMinutes: Int = 0
    @Published private(set) var lastActivity: Date?
    
    // MARK: - Initialization
    
    init(progressStore: LocalProgressStore, syncManager: SupabaseSyncManager) {
        self.progressStore = progressStore
        self.syncManager = syncManager
        
        // Load initial values
        updateFromStore()
    }
    
    // MARK: - Public Methods
    
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
        
        // Update view model state
        updateFromStore()
        
        // Sync to Supabase
        await syncInBackground()
    }
    
    // MARK: - Private Methods
    
    private func updateFromStore() {
        let newStreak = progressStore.streak
        let newDailyMinutes = progressStore.dailyMinutes
        let newTotalMinutes = progressStore.totalMinutes
        let newLastActivity = progressStore.lastActivity
        
        // Only update if values actually changed
        if streak != newStreak {
            streak = newStreak
        }
        if dailyMinutes != newDailyMinutes {
            dailyMinutes = newDailyMinutes
        }
        if totalMinutes != newTotalMinutes {
            totalMinutes = newTotalMinutes
        }
        if lastActivity != newLastActivity {
            lastActivity = newLastActivity
        }
        
        print("[Progress] Updated from store: streak=\(streak), daily=\(dailyMinutes), total=\(totalMinutes)")
    }
    
    func syncInBackground() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        print("[Progress] Starting background sync")
        await syncManager.syncSupabaseToLocal()
        updateFromStore()
        print("[Progress] Completed background sync")
    }
    
    // Test method for development only
    #if DEBUG
    func testRecordFiveMinutes() async {
        await updateProgress(minutes: 5)
    }
    #endif
} 