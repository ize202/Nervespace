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
    
    /// Handles a failed completion sync by storing it for later retry
    public func handleFailedSync(_ completion: Model.RoutineCompletion) {
        pendingStore.addPendingCompletion(completion)
    }
    
    /// Handles soft deletion of a completion
    public func deleteCompletion(id: UUID) async {
        guard let userId = db.currentUser?.id else { return }
        guard !isSyncing else { return }
        
        // Remove from local store first
        completionStore.removeCompletion(id: id)
        
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