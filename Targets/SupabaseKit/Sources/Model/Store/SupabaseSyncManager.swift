import Foundation

@MainActor
public class SupabaseSyncManager {
    private let db: DB
    private let progressStore: LocalProgressStore
    private let completionStore: RoutineCompletionStore
    
    @Published private(set) var isSyncing = false
    @Published var lastSyncError: Error?
    
    public init(db: DB, progressStore: LocalProgressStore, completionStore: RoutineCompletionStore) {
        self.db = db
        self.progressStore = progressStore
        self.completionStore = completionStore
    }
    
    // MARK: - Public Methods
    
    /// Syncs local progress data to Supabase
    public func syncLocalToSupabase() async {
        guard let userId = db.currentUser?.id else { return }
        guard !isSyncing else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            // Push progress
            _ = try await db.userService.updateProgress(
                userId: userId,
                streak: progressStore.streak,
                dailyMinutes: progressStore.dailyMinutes,
                totalMinutes: progressStore.totalMinutes,
                lastActivity: progressStore.lastActivity
            )
            
            lastSyncError = nil
        } catch {
            lastSyncError = error
            print("Error syncing to Supabase: \(error)")
        }
    }
    
    /// Fetches latest data from Supabase and updates local stores
    public func syncSupabaseToLocal() async {
        guard let userId = db.currentUser?.id else { return }
        guard !isSyncing else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            // Fetch progress
            let progress = try await db.userService.fetchProgress(userId: userId)
            progressStore.updateProgress(
                streak: progress.streak,
                dailyMinutes: progress.dailyMinutes,
                totalMinutes: progress.totalMinutes,
                lastActivity: progress.lastActivity
            )
            
            // Fetch completions
            let completions = try await db.userService.getRecentCompletions(userId: userId, days: 30)
            completionStore.updateCompletions(completions)
            
            lastSyncError = nil
        } catch {
            lastSyncError = error
            print("Error syncing from Supabase: \(error)")
        }
    }
    
    /// Performs a full sync in both directions
    public func performFullSync() async {
        await syncSupabaseToLocal()
        await syncLocalToSupabase()
    }
} 