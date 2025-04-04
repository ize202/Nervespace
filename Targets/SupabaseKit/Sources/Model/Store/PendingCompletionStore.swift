import Foundation
import SharedKit

/// Stores routine completions that failed to sync with Supabase for later retry
@MainActor
public class PendingCompletionStore: ObservableObject {
    @Published public private(set) var pendingCompletions: [PendingCompletion] = []
    @Published public private(set) var pendingDeletions: [PendingDeletion] = []
    
    private let fileManager: FileManager
    private let storeURL: URL
    private let deletionsURL: URL
    
    public init() {
        self.fileManager = .default
        
        // Get the app's Documents directory
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.storeURL = documentsDirectory.appendingPathComponent("pending_completions.json")
        self.deletionsURL = documentsDirectory.appendingPathComponent("pending_deletions.json")
        
        // Load initial data
        loadFromDisk()
    }
    
    // MARK: - Public Methods
    
    public func addPendingCompletion(_ completion: Model.RoutineCompletion) {
        let pending = PendingCompletion(
            completion: completion,
            lastAttempt: Date(),
            attemptCount: 0
        )
        pendingCompletions.append(pending)
        saveToDisk()
    }
    
    public func removePendingCompletion(id: UUID) {
        pendingCompletions.removeAll { $0.completion.id == id }
        saveToDisk()
    }
    
    public func updateAttempt(id: UUID) {
        if let index = pendingCompletions.firstIndex(where: { $0.completion.id == id }) {
            pendingCompletions[index].lastAttempt = Date()
            pendingCompletions[index].attemptCount += 1
            saveToDisk()
        }
    }
    
    public func addPendingDeletion(_ id: UUID) {
        let pending = PendingDeletion(
            id: id,
            lastAttempt: Date(),
            attemptCount: 0
        )
        pendingDeletions.append(pending)
        saveDeletionsToDisk()
    }
    
    public func removePendingDeletion(_ id: UUID) {
        pendingDeletions.removeAll { $0.id == id }
        saveDeletionsToDisk()
    }
    
    public func updateDeletionAttempt(_ id: UUID) {
        if let index = pendingDeletions.firstIndex(where: { $0.id == id }) {
            pendingDeletions[index].lastAttempt = Date()
            pendingDeletions[index].attemptCount += 1
            saveDeletionsToDisk()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadFromDisk() {
        do {
            if fileManager.fileExists(atPath: storeURL.path) {
                let data = try Data(contentsOf: storeURL)
                pendingCompletions = try JSONDecoder().decode([PendingCompletion].self, from: data)
            }
            
            if fileManager.fileExists(atPath: deletionsURL.path) {
                let data = try Data(contentsOf: deletionsURL)
                pendingDeletions = try JSONDecoder().decode([PendingDeletion].self, from: data)
            }
        } catch {
            print("Error loading pending data: \(error)")
        }
    }
    
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(pendingCompletions)
            try data.write(to: storeURL)
        } catch {
            print("Error saving pending completions: \(error)")
        }
    }
    
    private func saveDeletionsToDisk() {
        do {
            let data = try JSONEncoder().encode(pendingDeletions)
            try data.write(to: deletionsURL)
        } catch {
            print("Error saving pending deletions: \(error)")
        }
    }
}

/// Represents a completion that failed to sync with additional metadata
public struct PendingCompletion: Codable {
    public let completion: Model.RoutineCompletion
    public var lastAttempt: Date
    public var attemptCount: Int
}

/// Represents a deletion that failed to sync with additional metadata
public struct PendingDeletion: Codable {
    public let id: UUID
    public var lastAttempt: Date
    public var attemptCount: Int
} 