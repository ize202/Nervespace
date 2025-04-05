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
        
        // Load initial data
        loadFromDisk()
    }
    
    // MARK: - Public Methods
    
    public func addCompletion(_ completion: Model.RoutineCompletion) {
        completions.append(completion)
        saveToDisk()
    }
    
    public func removeCompletion(id: UUID) {
        completions.removeAll { $0.id == id }
        saveToDisk()
    }
    
    public func getCompletion(id: UUID) -> Model.RoutineCompletion? {
        return completions.first { $0.id == id }
    }
    
    public func getRecentCompletions(days: Int = 30) -> [Model.RoutineCompletion] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return completions.filter { $0.completedAt >= cutoffDate }
    }
    
    public func updateCompletions(_ newCompletions: [Model.RoutineCompletion]) {
        completions = newCompletions
        saveToDisk()
    }
    
    // MARK: - Private Methods
    
    private func loadFromDisk() {
        do {
            guard fileManager.fileExists(atPath: storeURL.path) else { return }
            
            let data = try Data(contentsOf: storeURL)
            completions = try JSONDecoder().decode([Model.RoutineCompletion].self, from: data)
        } catch {
            print("Error loading completions: \(error)")
        }
    }
    
    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(completions)
            try data.write(to: storeURL)
        } catch {
            print("Error saving completions: \(error)")
        }
    }
} 