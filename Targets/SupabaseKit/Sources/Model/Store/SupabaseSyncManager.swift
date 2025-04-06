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
    @Published private(set) var hasFetchedInitialProgress = false
    
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
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            // First, try to sync any pending completions
            await syncPendingCompletions()
            
            // Then sync any new completions that aren't in pending
            let localCompletions = completionStore.getRecentCompletions()
            let serverCompletions = try await db.userService.getRecentCompletions(userId: userId, days: 30)
            
            // Find completions that exist locally but not on server
            let serverIds = Set(serverCompletions.map { $0.id })
            let newCompletions = localCompletions.filter { !serverIds.contains($0.id) }
            
            print("[Sync] Found \(newCompletions.count) new completions to sync")
            
            // Sync each new completion
            for completion in newCompletions {
                do {
                    print("[Sync] Recording completion: id=\(completion.id), routineId=\(completion.routineId)")
                    _ = try await db.userService.recordRoutineCompletion(
                        routineId: completion.routineId,
                        durationMinutes: completion.durationMinutes,
                        userId: userId
                    )
                } catch {
                    print("[Sync] Failed to record completion \(completion.id): \(error)")
                    // Add to pending store for retry
                    pendingStore.addPendingCompletion(completion)
                }
            }
            
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
                
                // Only do initial load if we haven't fetched yet and have no local data
                if !hasFetchedInitialProgress && progressStore.lastActivity == nil {
                    print("[Sync] Initial load - using remote data")
                    progressStore.updateProgress(
                        streak: progress.streak,
                        dailyMinutes: progress.dailyMinutes,
                        totalMinutes: progress.totalMinutes,
                        lastActivity: progress.lastActivity
                    )
                    hasFetchedInitialProgress = true
                } else {
                    // For subsequent syncs, merge data intelligently
                    let calendar = Calendar.current
                    let today = calendar.startOfDay(for: Date())
                    
                    // Get the most up-to-date values
                    let updatedStreak = max(progress.streak, progressStore.streak)
                    let updatedTotalMinutes = max(progress.totalMinutes, progressStore.totalMinutes)
                    
                    // For daily minutes, prefer local value if it's from today
                    var updatedDailyMinutes = progressStore.dailyMinutes
                    if let localDate = progressStore.lastActivity,
                       calendar.isDate(calendar.startOfDay(for: localDate), inSameDayAs: today) {
                        // Keep local daily minutes if we have activity today
                        print("[Sync] Using local daily minutes: \(updatedDailyMinutes)")
                    } else if let remoteDate = progress.lastActivity,
                              calendar.isDate(calendar.startOfDay(for: remoteDate), inSameDayAs: today) {
                        // Use remote daily minutes if local isn't from today but remote is
                        updatedDailyMinutes = progress.dailyMinutes
                        print("[Sync] Using remote daily minutes: \(updatedDailyMinutes)")
                    } else {
                        // Neither is from today, reset daily minutes
                        updatedDailyMinutes = 0
                        print("[Sync] Resetting daily minutes - no activity today")
                    }
                    
                    // Use the most recent last activity
                    let updatedLastActivity: Date?
                    if let localDate = progressStore.lastActivity,
                       let remoteDate = progress.lastActivity {
                        updatedLastActivity = localDate > remoteDate ? localDate : remoteDate
                    } else {
                        updatedLastActivity = progressStore.lastActivity ?? progress.lastActivity
                    }
                    
                    print("[Sync] Updating local state - streak: \(updatedStreak), daily: \(updatedDailyMinutes), total: \(updatedTotalMinutes)")
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