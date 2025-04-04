import Foundation
import SharedKit

/// Stores routine completions that failed to sync with Supabase for later retry
@MainActor
public class PendingCompletionStore: ObservableObject {
    @Published private(set) var pendingCompletions: [PendingCompletion] = []
    
    private let fileManager: FileManager
    private let storeURL: URL
    
    public init() {
        self.fileManager = .default
        
        // Get the app's Documents directory
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.storeURL = documentsDirectory.appendingPathComponent("pending_completions.json")
        
        // Load initial data
        loadFromDisk()
    }
    
    // MARK: - Public Methods
    
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
    
    // MARK: - Private Methods
    
    private func loadFromDisk() {
        do {
            guard fileManager.fileExists(atPath: storeURL.path) else { return }
            
            let data = try Data(contentsOf: storeURL)
            pendingCompletions = try JSONDecoder().decode([PendingCompletion].self, from: data)
        } catch {
            print("Error loading pending completions: \(error)")
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
}

/// Represents a completion that failed to sync with additional metadata
struct PendingCompletion: Codable {
    let completion: Model.RoutineCompletion
    var lastAttempt: Date
    var attemptCount: Int
} 