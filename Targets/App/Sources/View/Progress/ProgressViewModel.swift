import SwiftUI
import SharedKit
import SupabaseKit

@MainActor
final class ProgressViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @AppStorage("streak") private var cachedStreak: Int = 0
    @AppStorage("dailyMinutes") private var cachedDailyMinutes: Int = 0
    @AppStorage("totalMinutes") private var cachedTotalMinutes: Int = 0
    @AppStorage("lastActivity") private var cachedLastActivityTimestamp: TimeInterval = 0
    
    @Published private(set) var streak: Int = 0
    @Published private(set) var dailyMinutes: Int = 0
    @Published private(set) var totalMinutes: Int = 0
    @Published private(set) var lastActivity: Date?
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    // MARK: - Private Properties
    
    private let calendar = Calendar.current
    private let db: DB
    private var userId: UUID? { db.currentUser?.id }
    
    // MARK: - Initialization
    
    init(db: DB) {
        self.db = db
        loadFromCache()
    }
    
    // MARK: - Public Methods
    
    func refreshFromSupabase() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let userId = userId else {
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user ID available"])
            return
        }
        
        do {
            let progress = try await db.userService.fetchProgress(userId: userId)
            
            // Compare server and local values
            let serverValues = (
                streak: progress.streak,
                dailyMinutes: progress.dailyMinutes,
                totalMinutes: progress.totalMinutes,
                lastActivity: progress.lastActivity
            )
            
            let localValues = (
                streak: streak,
                dailyMinutes: dailyMinutes,
                totalMinutes: totalMinutes,
                lastActivity: lastActivity
            )
            
            // Take max values between local and server
            let mergedValues = (
                streak: max(serverValues.streak, localValues.streak),
                dailyMinutes: max(serverValues.dailyMinutes, localValues.dailyMinutes),
                totalMinutes: max(serverValues.totalMinutes, localValues.totalMinutes),
                lastActivity: localValues.lastActivity ?? serverValues.lastActivity
            )
            
            // Update local storage with merged values
            streak = mergedValues.streak
            dailyMinutes = mergedValues.dailyMinutes
            totalMinutes = mergedValues.totalMinutes
            lastActivity = mergedValues.lastActivity
            
            // Only sync back if numerical values are ahead of server
            if mergedValues.streak > serverValues.streak ||
               mergedValues.dailyMinutes > serverValues.dailyMinutes ||
               mergedValues.totalMinutes > serverValues.totalMinutes {
                await syncToServer()
            }
            
        } catch {
            self.error = error
            
            // Try to initialize progress if it doesn't exist
            do {
                let progress = try await db.userService.initializeProgress(userId: userId)
                
                // Update local storage with initial values
                streak = progress.streak
                dailyMinutes = progress.dailyMinutes
                totalMinutes = progress.totalMinutes
                lastActivity = progress.lastActivity
                
            } catch {
                self.error = error
            }
        }
    }
    
    func updateProgress(minutes: Int) async {
        guard minutes > 0 else { return }
        
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        // Calculate new values
        var newDailyMinutes = minutes
        var newStreak = 1
        
        if let lastActivity = lastActivity {
            let lastActivityDay = calendar.startOfDay(for: lastActivity)
            
            if lastActivityDay == startOfToday {
                // More activity today
                newDailyMinutes = dailyMinutes + minutes
            } else if calendar.isDate(lastActivityDay, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: startOfToday)!) {
                // Activity on consecutive day
                newStreak = streak + 1
            }
        }
        
        let newTotalMinutes = totalMinutes + minutes
        
        // Update local values immediately
        updateLocalValues(
            streak: newStreak,
            dailyMinutes: newDailyMinutes,
            totalMinutes: newTotalMinutes,
            lastActivity: now
        )
        
        // Sync to server in background
        await syncToServer()
    }
    
    // Test method for development only
    #if DEBUG
    func testRecordFiveMinutes() async {
        await updateProgress(minutes: 5)
    }
    #endif
    
    // MARK: - Private Methods
    
    private func loadFromCache() {
        streak = cachedStreak
        dailyMinutes = cachedDailyMinutes
        totalMinutes = cachedTotalMinutes
        lastActivity = cachedLastActivityTimestamp > 0 ? Date(timeIntervalSince1970: cachedLastActivityTimestamp) : nil
    }
    
    private func updateLocalValues(streak: Int, dailyMinutes: Int, totalMinutes: Int, lastActivity: Date?) {
        // Update @AppStorage values
        self.cachedStreak = streak
        self.cachedDailyMinutes = dailyMinutes
        self.cachedTotalMinutes = totalMinutes
        self.cachedLastActivityTimestamp = lastActivity?.timeIntervalSince1970 ?? 0
        
        // Update @Published values
        self.streak = streak
        self.dailyMinutes = dailyMinutes
        self.totalMinutes = totalMinutes
        self.lastActivity = lastActivity
    }
    
    private func syncToServer() async {
        guard let userId = userId else { return }
        
        do {
            _ = try await db.userService.updateProgress(
                userId: userId,
                streak: streak,
                dailyMinutes: dailyMinutes,
                totalMinutes: totalMinutes,
                lastActivity: lastActivity
            )
        } catch {
            self.error = error
        }
    }
    
    private func latestDate(_ date1: Date?, _ date2: Date?) -> Date? {
        switch (date1, date2) {
        case (nil, nil): return nil
        case (let date?, nil): return date
        case (nil, let date?): return date
        case (let date1?, let date2?): return date1 > date2 ? date1 : date2
        }
    }
} 