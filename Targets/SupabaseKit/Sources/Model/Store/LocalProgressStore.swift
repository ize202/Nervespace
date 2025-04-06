import Foundation
import SwiftUI

@MainActor
public class LocalProgressStore: ObservableObject {
    @AppStorage("streak") public private(set) var streak: Int = 0
    @AppStorage("dailyMinutes") public private(set) var dailyMinutes: Int = 0
    @AppStorage("totalMinutes") public private(set) var totalMinutes: Int = 0
    @AppStorage("dailyGoal") public var dailyGoal: Int = 5
    @AppStorage("lastActivityDate") private var lastActivityDateString: String = "" {
        didSet {
            print("[Progress] Last activity date string updated: '\(oldValue)' -> '\(lastActivityDateString)'")
        }
    }
    
    private let calendar = Calendar.current
    private let rolloverHour: Int = 4  // Day rolls over at 4 AM
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    @Published public private(set) var lastActivity: Date? {
        didSet {
            if let date = lastActivity {
                let dateString = dateFormatter.string(from: date)
                print("[Progress] Setting last activity date string: '\(dateString)'")
                lastActivityDateString = dateString
            } else {
                print("[Progress] Clearing last activity date string")
                lastActivityDateString = ""
            }
        }
    }
    
    public init() {
        print("[Progress] Initializing LocalProgressStore")
        print("[Progress] Initial values - streak: \(streak), daily: \(dailyMinutes), total: \(totalMinutes)")
        print("[Progress] Initial last activity string: '\(lastActivityDateString)'")
        
        // Load last activity from storage
        if !lastActivityDateString.isEmpty {
            if let date = dateFormatter.date(from: lastActivityDateString) {
                lastActivity = date
                print("[Progress] Loaded last activity: \(date)")
                
                // Reset daily minutes if last activity wasn't today
                let lastDay = calendar.startOfDay(for: date)
                let today = calendar.startOfDay(for: Date())
                
                print("[Progress] Comparing days - Last: \(lastDay), Today: \(today)")
                if !calendar.isDate(lastDay, inSameDayAs: today) {
                    print("[Progress] Last activity was not today, resetting daily minutes")
                    dailyMinutes = 0
                } else {
                    print("[Progress] Last activity was today, keeping daily minutes: \(dailyMinutes)")
                }
            } else {
                print("[Progress] Failed to parse last activity date: '\(lastActivityDateString)'")
            }
        } else {
            print("[Progress] No last activity date stored")
        }
    }
    
    public func updateProgress(streak: Int, dailyMinutes: Int, totalMinutes: Int, lastActivity: Date?) {
        print("[Progress] Updating progress - streak: \(streak), daily: \(dailyMinutes), total: \(totalMinutes), lastActivity: \(lastActivity?.description ?? "nil")")
        
        // Only update last activity if it's more recent than what we have
        if let newActivity = lastActivity {
            if let currentActivity = self.lastActivity {
                if newActivity > currentActivity {
                    self.lastActivity = newActivity
                }
            } else {
                self.lastActivity = newActivity
            }
        }
        
        self.streak = streak
        self.dailyMinutes = dailyMinutes
        self.totalMinutes = totalMinutes
        objectWillChange.send()
    }
    
    public func resetDailyProgress() {
        print("[Progress] Resetting daily minutes from \(dailyMinutes) to 0")
        self.dailyMinutes = 0
        objectWillChange.send()
    }
    
    private func isToday(_ date: Date) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let otherDay = calendar.startOfDay(for: date)
        return calendar.isDate(today, inSameDayAs: otherDay)
    }
    
    public func addCompletion(durationMinutes: Int) {
        let now = Date()
        print("[Progress] Adding completion: \(durationMinutes) minutes at \(now)")
        print("[Progress] Current last activity: \(lastActivity?.description ?? "nil")")
        
        // Update streak
        if let last = lastActivity {
            let lastDay = calendar.startOfDay(for: last)
            let today = calendar.startOfDay(for: now)
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            
            if calendar.isDate(lastDay, inSameDayAs: yesterday) {
                streak += 1
            } else if !calendar.isDate(lastDay, inSameDayAs: today) {
                streak = 1
            }
        } else {
            streak = 1
        }
        
        // Update minutes
        if let last = lastActivity, isToday(last) {
            // Same day - add to daily minutes
            print("[Progress] Same day - adding \(durationMinutes) to daily minutes")
            dailyMinutes += durationMinutes
        } else {
            // New day or first activity - reset daily minutes
            print("[Progress] New day - setting daily minutes to \(durationMinutes)")
            dailyMinutes = durationMinutes
        }
        
        // Update total minutes and last activity
        totalMinutes += durationMinutes
        lastActivity = now
        
        print("[Progress] Updated state - streak: \(streak), daily: \(dailyMinutes), total: \(totalMinutes), lastActivity: \(lastActivity?.description ?? "nil")")
        objectWillChange.send()
    }
} 