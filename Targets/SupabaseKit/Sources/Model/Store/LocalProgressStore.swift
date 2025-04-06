import Foundation
import SwiftUI

@MainActor
public class LocalProgressStore: ObservableObject {
    @AppStorage("streak") public private(set) var streak: Int = 0
    @AppStorage("dailyMinutes") public private(set) var dailyMinutes: Int = 0
    @AppStorage("totalMinutes") public private(set) var totalMinutes: Int = 0
    @AppStorage("lastActivity") private var lastActivityTimestamp: TimeInterval = 0
    
    private let calendar = Calendar.current
    private let rolloverHour: Int = 4  // Day rolls over at 4 AM
    
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
    
    @available(*, deprecated, message: "Use addCompletion(durationMinutes:) instead")
    public func addMinutes(_ minutes: Int) {
        addCompletion(durationMinutes: minutes)
    }
    
    /// Gets the "fitness day" start for a given date, using rollover hour
    private func fitnessDay(for date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        if let hour = components.hour, hour < rolloverHour {
            // If it's before rollover, consider it part of the previous day
            return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: date))!
        }
        return calendar.startOfDay(for: date)
    }
    
    /// Records a routine completion and updates streak based on calendar dates
    /// - Parameter durationMinutes: Duration of the completed routine in minutes
    public func addCompletion(durationMinutes: Int) {
        let now = Date()
        let today = fitnessDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let previous = self.lastActivity.map { fitnessDay(for: $0) }
        
        // Update streak based on consecutive days logic
        if let previous = previous {
            if calendar.isDate(previous, inSameDayAs: yesterday) {
                // Last activity was yesterday → increment streak
                self.streak += 1
            } else if calendar.isDate(previous, inSameDayAs: today) {
                // Last activity was today → keep streak
            } else {
                // Gap in activity → reset streak
                self.streak = 1
            }
        } else {
            // First ever activity → start streak at 1
            self.streak = 1
        }
        
        // Update minutes
        if let previous = previous, calendar.isDate(previous, inSameDayAs: today) {
            // Same day - add to daily minutes
            self.dailyMinutes += durationMinutes
        } else {
            // New day - reset daily minutes
            self.dailyMinutes = durationMinutes
        }
        
        self.totalMinutes += durationMinutes
        self.lastActivity = now
    }
} 