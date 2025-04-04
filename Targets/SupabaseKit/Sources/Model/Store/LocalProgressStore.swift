import Foundation
import SwiftUI

@MainActor
public class LocalProgressStore: ObservableObject {
    @AppStorage("streak") public private(set) var streak: Int = 0
    @AppStorage("dailyMinutes") public private(set) var dailyMinutes: Int = 0
    @AppStorage("totalMinutes") public private(set) var totalMinutes: Int = 0
    @AppStorage("lastActivity") private var lastActivityTimestamp: TimeInterval = 0
    
    @Published public private(set) var lastActivity: Date? {
        didSet {
            lastActivityTimestamp = lastActivity?.timeIntervalSince1970 ?? 0
        }
    }
    
    public init() {
        // Initialize lastActivity from timestamp
        if lastActivityTimestamp > 0 {
            lastActivity = Date(timeIntervalSince1970: lastActivityTimestamp)
        }
    }
    
    public func updateProgress(streak: Int, dailyMinutes: Int, totalMinutes: Int, lastActivity: Date?) {
        self.streak = streak
        self.dailyMinutes = dailyMinutes
        self.totalMinutes = totalMinutes
        self.lastActivity = lastActivity
    }
    
    public func resetDailyProgress() {
        self.dailyMinutes = 0
    }
    
    public func addMinutes(_ minutes: Int) {
        self.dailyMinutes += minutes
        self.totalMinutes += minutes
        self.lastActivity = Date()
        
        // Streak logic could be enhanced later
        if self.dailyMinutes >= 5 { // Minimum daily goal
            self.streak += 1
        }
    }
} 