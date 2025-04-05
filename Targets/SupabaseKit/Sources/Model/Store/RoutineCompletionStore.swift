import Foundation
import SharedKit

@MainActor
public class RoutineCompletionStore: ObservableObject {
    @Published public private(set) var completions: [Model.RoutineCompletion] = []
    
    private let fileManager: FileManager
    private let storeURL: URL
    
    public init() {
        self.fileManager = .default
        
        // Get the app's Documents directory
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.storeURL = documentsDirectory.appendingPathComponent("routine_completions.json")
        print("[CompletionStore] Initialized with store at: \(storeURL.path)")
        
        // Load initial data
        loadFromDisk()
    }
    
    // MARK: - Public Methods
    
    public func addCompletion(_ completion: Model.RoutineCompletion) {
        print("[CompletionStore] Adding completion: id=\(completion.id), routineId=\(completion.routineId)")
        completions.append(completion)
        saveToDisk()
        print("[CompletionStore] Current completion count: \(completions.count)")
    }
    
    public func removeCompletion(id: UUID) {
        print("[CompletionStore] Removing completion: \(id)")
        completions.removeAll { $0.id == id }
        saveToDisk()
    }
    
    public func getCompletion(id: UUID) -> Model.RoutineCompletion? {
        let completion = completions.first { $0.id == id }
        print("[CompletionStore] Getting completion \(id): \(completion != nil ? "found" : "not found")")
        return completion
    }
    
    public func getRecentCompletions(days: Int = 30) -> [Model.RoutineCompletion] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let recentCompletions = completions.filter { $0.completedAt >= cutoffDate }
        print("[CompletionStore] Getting recent completions: found \(recentCompletions.count)")
        return recentCompletions
    }
    
    public func updateCompletions(_ newCompletions: [Model.RoutineCompletion]) {
        print("[CompletionStore] Updating all completions: count=\(newCompletions.count)")
        completions = newCompletions
        saveToDisk()
    }
    
    // MARK: - Private Methods
    
    private func loadFromDisk() {
        do {
            guard fileManager.fileExists(atPath: storeURL.path) else {
                print("[CompletionStore] No existing store file found")
                return
            }
            
            let data = try Data(contentsOf: storeURL)
            completions = try JSONDecoder().decode([Model.RoutineCompletion].self, from: data)
            print("[CompletionStore] Loaded \(completions.count) completions from disk")
        } catch {
            print("[CompletionStore] Error loading completions: \(error)")
        }
    }
    
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(completions)
            try data.write(to: storeURL)
            print("[CompletionStore] Saved \(completions.count) completions to disk")
        } catch {
            print("[CompletionStore] Error saving completions: \(error)")
        }
    }
} 