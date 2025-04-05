import Foundation
import SwiftUI

@MainActor
public class SupabaseSyncManager: ObservableObject {
    public private(set) var db: DB
    private let progressStore: LocalProgressStore
    private let completionStore: RoutineCompletionStore
    private let pendingStore: PendingCompletionStore
    
    @Published private(set) var isSyncing = false
    @Published var lastSyncError: Error?
    private var hasFetchedInitialProgress = false
    
    public init(
        db: DB,
        progressStore: LocalProgressStore,
        completionStore: RoutineCompletionStore,
        pendingStore: PendingCompletionStore
    ) {
        self.db = db
        self.progressStore = progressStore
        self.completionStore = completionStore
        self.pendingStore = pendingStore
    }
    
    // MARK: - Public Methods
    
    /// Syncs local progress data to Supabase
    public func syncLocalToSupabase() async {
        guard let userId = db.currentUser?.id else { return }
        guard !isSyncing else { return }
        
        // Skip if we haven't fetched initial progress yet
        guard hasFetchedInitialProgress else {
            print("[Sync] Skipping push — haven't fetched initial progress yet")
            return
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            // First, try to sync any pending completions
            await syncPendingCompletions()
            
            // Log the values we're about to push
            print("[Sync] Pushing to Supabase: streak=\(progressStore.streak), dailyMinutes=\(progressStore.dailyMinutes), totalMinutes=\(progressStore.totalMinutes)")
            
            // Then sync progress
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
            // First, try to sync any pending completions
            await syncPendingCompletions()
            
            // Fetch progress
            do {
                let progress = try await db.userService.fetchProgress(userId: userId)
                
                // Smart merging of progress data
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let progressDate = progress.lastActivity.map { calendar.startOfDay(for: $0) }
                
                // Wait to trust fetched progress until it has valid dailyMinutes
                let isValidInitial = progress.dailyMinutes > 0
                
                // Log the values we received
                print("[Sync] Received from Supabase: streak=\(progress.streak), dailyMinutes=\(progress.dailyMinutes), totalMinutes=\(progress.totalMinutes), isValid=\(isValidInitial)")
                
                if !hasFetchedInitialProgress {
                    if isValidInitial {
                        print("[Sync] Confirmed valid initial progress from Supabase")
                        progressStore.updateProgress(
                            streak: progress.streak,
                            dailyMinutes: progress.dailyMinutes,
                            totalMinutes: progress.totalMinutes,
                            lastActivity: progress.lastActivity
                        )
                        hasFetchedInitialProgress = true
                    } else {
                        print("[Sync] Ignoring initial progress — probably uninitialized or stale")
                        return
                    }
                } else {
                    // Normal sync logic for subsequent fetches
                    let updatedStreak = max(progress.streak, progressStore.streak)
                    var updatedDailyMinutes = progressStore.dailyMinutes
                    
                    // If remote lastActivity is today and has higher minutes, use remote daily minutes
                    if let lastDate = progressDate, calendar.isDate(lastDate, inSameDayAs: today),
                       progress.dailyMinutes > progressStore.dailyMinutes {
                        updatedDailyMinutes = progress.dailyMinutes
                    }
                    
                    // Always use the higher total minutes
                    let updatedTotalMinutes = max(progress.totalMinutes, progressStore.totalMinutes)
                    
                    // Use the most recent lastActivity
                    let updatedLastActivity: Date?
                    if let localDate = progressStore.lastActivity, let remoteDate = progress.lastActivity {
                        updatedLastActivity = localDate > remoteDate ? localDate : remoteDate
                    } else {
                        updatedLastActivity = progressStore.lastActivity ?? progress.lastActivity
                    }
                    
                    // Log the values we're about to update locally
                    print("[Sync] Updating local state with progress: streak=\(updatedStreak), dailyMinutes=\(updatedDailyMinutes), totalMinutes=\(updatedTotalMinutes)")
                    
                    // Update local store with merged data
                    progressStore.updateProgress(
                        streak: updatedStreak,
                        dailyMinutes: updatedDailyMinutes,
                        totalMinutes: updatedTotalMinutes,
                        lastActivity: updatedLastActivity
                    )
                }
            } catch {
                print("Error fetching progress: \(error). Using local data only.")
            }
            
            // Fetch completions
            do {
                let completions = try await db.userService.getRecentCompletions(userId: userId, days: 30)
                completionStore.updateCompletions(completions)
            } catch {
                print("Error fetching completions: \(error). Using local data only.")
            }
            
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
    
    /// Handles a failed completion sync by storing it for later retry
    public func handleFailedSync(_ completion: Model.RoutineCompletion) {
        pendingStore.addPendingCompletion(completion)
    }
    
    /// Handles soft deletion of a completion
    public func deleteCompletion(id: UUID) async {
        guard let userId = db.currentUser?.id else { return }
        guard !isSyncing else { return }
        
        // Get the completion before removing it
        let completionToDelete = completionStore.getCompletion(id: id)
        
        // Remove from local store first
        completionStore.removeCompletion(id: id)
        
        // If completion was found, adjust progress
        if let completion = completionToDelete {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let completionDate = calendar.startOfDay(for: completion.completedAt)
            
            // Adjust total minutes (always)
            let newTotalMinutes = max(0, progressStore.totalMinutes - completion.durationMinutes)
            
            // Adjust daily minutes only if the completion was from today
            let newDailyMinutes: Int
            if calendar.isDate(completionDate, inSameDayAs: today) {
                newDailyMinutes = max(0, progressStore.dailyMinutes - completion.durationMinutes)
            } else {
                newDailyMinutes = progressStore.dailyMinutes
            }
            
            // Update the progress store
            progressStore.updateProgress(
                streak: progressStore.streak, // Keep streak the same
                dailyMinutes: newDailyMinutes,
                totalMinutes: newTotalMinutes,
                lastActivity: progressStore.lastActivity // Keep last activity the same
            )
            
            print("[Sync] Adjusted progress after deletion: daily=\(newDailyMinutes), total=\(newTotalMinutes)")
        }
        
        do {
            // Try to soft delete in Supabase
            try await db.userService.softDeleteCompletion(completionId: id, userId: userId)
        } catch {
            // If deletion fails, store the deletion intent for later retry
            pendingStore.addPendingDeletion(id)
            lastSyncError = error
            print("Error deleting completion: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Attempts to sync pending completions with Supabase
    private func syncPendingCompletions() async {
        guard let userId = db.currentUser?.id else { return }
        
        // Create a local copy to avoid mutation during iteration
        let pendingCompletions = pendingStore.pendingCompletions
        
        for pending in pendingCompletions {
            do {
                // Record completion with Supabase
                _ = try await db.userService.recordRoutineCompletion(
                    routineId: pending.completion.routineId,
                    durationMinutes: pending.completion.durationMinutes,
                    userId: userId
                )
                
                // If successful, remove from pending store
                pendingStore.removePendingCompletion(id: pending.completion.id)
            } catch {
                // Update attempt count and timestamp
                pendingStore.updateAttempt(id: pending.completion.id)
                print("Failed to sync pending completion: \(error)")
            }
        }
    }
} 