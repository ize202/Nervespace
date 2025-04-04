import SwiftUI

@MainActor
public class SyncCoordinator: ObservableObject {
    private let syncManager: SupabaseSyncManager
    private let minimumSyncInterval: TimeInterval = 300 // 5 minutes
    private var lastSyncTime: Date?
    
    public init(syncManager: SupabaseSyncManager) {
        self.syncManager = syncManager
    }
    
    public func shouldSync() -> Bool {
        guard let lastSync = lastSyncTime else { return true }
        return Date().timeIntervalSince(lastSync) >= minimumSyncInterval
    }
    
    public func performSync() async {
        guard shouldSync() else { return }
        
        await syncManager.performFullSync()
        lastSyncTime = Date()
    }
    
    public func forceSync() async {
        await syncManager.performFullSync()
        lastSyncTime = Date()
    }
} 