import Foundation
import SupabaseKit
import SharedKit

@MainActor
class ProgressManager: ObservableObject {
    private static var _shared: ProgressManager?
    
    static var shared: ProgressManager {
        if _shared == nil {
            _shared = ProgressManager()
        }
        return _shared!
    }
    
    private let db: DB
    private let defaults = UserDefaults.standard
    private let deviceIdKey = "device_uuid"
    
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var totalMinutes: Int = 0
    @Published private(set) var routineCompletions: Int = 0
    @Published private(set) var lastActivity: Date?
    
    // Device UUID for anonymous users
    private var deviceId: UUID {
        if let storedId = defaults.string(forKey: deviceIdKey),
           let uuid = UUID(uuidString: storedId) {
            return uuid
        }
        let newId = UUID()
        defaults.set(newId.uuidString, forKey: deviceIdKey)
        return newId
    }
    
    init(db: DB = DB()) {
        self.db = db
        loadLocalProgress()
    }
    
    // Load progress from local storage first
    private func loadLocalProgress() {
        currentStreak = defaults.integer(forKey: "local_streak")
        totalMinutes = defaults.integer(forKey: "local_minutes")
        routineCompletions = defaults.integer(forKey: "local_completions")
        lastActivity = defaults.object(forKey: "local_last_activity") as? Date
    }
    
    // Save progress to local storage
    private func saveLocalProgress() {
        defaults.set(currentStreak, forKey: "local_streak")
        defaults.set(totalMinutes, forKey: "local_minutes")
        defaults.set(routineCompletions, forKey: "local_completions")
        defaults.set(lastActivity, forKey: "local_last_activity")
    }
    
    func loadProgress() async throws {
        // Try to load from Supabase if user is authenticated
        if db.authState == .signedIn, let userId = db.currentUser?.id {
            let progress = try await db.userService.fetchProgress(userId: userId)
            await updateLocalProgress(from: progress)
        } else {
            // For anonymous users, try to load using device ID
            do {
                let progress = try await db.userService.fetchProgress(userId: deviceId)
                await updateLocalProgress(from: progress)
            } catch {
                // If no remote progress exists, keep using local progress
                print("No remote progress found for anonymous user, using local")
            }
        }
    }
    
    @MainActor
    private func updateLocalProgress(from progress: UserProgress) {
        currentStreak = progress.streak
        totalMinutes = progress.totalMinutes
        routineCompletions = progress.routineCompletions
        lastActivity = progress.lastActivity
        saveLocalProgress()
    }
    
    func recordCompletion(routine: Routine) async throws {
        let today = Date()
        let calendar = Calendar.current
        
        // Calculate new streak
        var newStreak = currentStreak
        if let lastActivity = lastActivity {
            if calendar.isDateInYesterday(lastActivity) {
                newStreak += 1
            } else if !calendar.isDateInToday(lastActivity) {
                newStreak = 1
            }
        } else {
            newStreak = 1
        }
        
        // Update local state first
        currentStreak = newStreak
        totalMinutes += routine.totalDuration / 60
        routineCompletions += 1
        lastActivity = today
        saveLocalProgress()
        
        // Then try to sync with backend
        let userId = db.currentUser?.id ?? deviceId
        
        do {
            let progress = try await db.userService.updateProgress(
                userId: userId,
                streak: newStreak,
                routineCompletions: routineCompletions,
                totalMinutes: totalMinutes,
                lastActivity: today
            )
            // Update local state with server response
            await updateLocalProgress(from: progress)
        } catch {
            print("Failed to sync progress with server: \(error.localizedDescription)")
            // Continue with local progress
        }
    }
    
    // Call this when user creates an account to migrate anonymous data
    func migrateAnonymousData(to userId: UUID) async throws {
        guard db.authState == .signedIn else { return }
        
        // Create new progress entry for authenticated user
        try await db.userService.updateProgress(
            userId: userId,
            streak: currentStreak,
            routineCompletions: routineCompletions,
            totalMinutes: totalMinutes,
            lastActivity: lastActivity
        )
        
        // Optionally, delete the anonymous data
        // try await db.userService.deleteProgress(userId: deviceId)
    }
} 