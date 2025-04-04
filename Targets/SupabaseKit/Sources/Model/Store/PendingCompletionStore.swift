import Foundation
import SharedKit

/// Stores routine completions that failed to sync with Supabase for later retry
@MainActor
public class PendingCompletionStore: ObservableObject {
    @Published private(set) var pendingCompletions: [PendingCompletion] = []
    @Published private(set) var pendingDeletions: [PendingDeletion] = []
    
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
    
    // MARK: - Public Methods for Completions
    
    func addPendingCompletion(_ completion: Model.RoutineCompletion) {
        let pending = PendingCompletion(
            completion: completion,
            lastAttempt: Date(),
            attemptCount: 0
        )
        pendingCompletions.append(pending)
        saveToDisk()
    }
    
    func removePendingCompletion(id: UUID) {
        pendingCompletions.removeAll { $0.completion.id == id }
        saveToDisk()
    }
    
    func updateAttempt(id: UUID) {
        if let index = pendingCompletions.firstIndex(where: { $0.completion.id == id }) {
            pendingCompletions[index].lastAttempt = Date()
            pendingCompletions[index].attemptCount += 1
            saveToDisk()
        }
    }
    
    // MARK: - Public Methods for Deletions
    
    func addPendingDeletion(_ id: UUID) {
        let pending = PendingDeletion(
            id: id,
            lastAttempt: Date(),
            attemptCount: 0
        )
        pendingDeletions.append(pending)
        saveToDisk()
    }
    
    func removePendingDeletion(_ id: UUID) {
        pendingDeletions.removeAll { $0.id == id }
        saveToDisk()
    }
    
    func updateDeletionAttempt(_ id: UUID) {
        if let index = pendingDeletions.firstIndex(where: { $0.id == id }) {
            pendingDeletions[index].lastAttempt = Date()
            pendingDeletions[index].attemptCount += 1
            saveToDisk()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadFromDisk() {
        do {
            // Load pending completions
            if fileManager.fileExists(atPath: storeURL.path) {
                let data = try Data(contentsOf: storeURL)
                pendingCompletions = try JSONDecoder().decode([PendingCompletion].self, from: data)
            }
            
            // Load pending deletions
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
            // Save pending completions
            let completionsData = try JSONEncoder().encode(pendingCompletions)
            try completionsData.write(to: storeURL)
            
            // Save pending deletions
            let deletionsData = try JSONEncoder().encode(pendingDeletions)
            try deletionsData.write(to: deletionsURL)
        } catch {
            print("Error saving pending data: \(error)")
        }
    }
}

/// Represents a completion that failed to sync with additional metadata
struct PendingCompletion: Codable {
    let completion: Model.RoutineCompletion
    var lastAttempt: Date
    var attemptCount: Int
}

/// Represents a deletion that failed to sync with additional metadata
struct PendingDeletion: Codable {
    let id: UUID
    var lastAttempt: Date
    var attemptCount: Int
} 