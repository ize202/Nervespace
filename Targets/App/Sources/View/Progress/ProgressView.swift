import SwiftUI
import SharedKit
import SupabaseKit

struct ProgressView: View {
    @EnvironmentObject private var db: DB
    private let currentDate = Date()
    @State private var streakDays: Set<Date> = []
    
    // Daily goal in minutes (we can move this to user settings later)
    private let dailyGoal = 5
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    private var currentMinutes: Int {
        guard let lastActivity = db.lastActivity else { return 0 }
        return calendar.isDateInToday(lastActivity) ? db.dailyMinutes : 0
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.baseBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
                        // Header
                        HStack {
                            Text("Progress")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        VStack(spacing: 20) {
                            // Calendar Card
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Label("\(db.currentStreak)-Day Streak", systemImage: "flame.fill")
                                        .font(.headline)
                                        .foregroundColor(.brandPrimary)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: HistoryView()) {
                                        HStack(spacing: 4) {
                                            Text("History")
                                                .font(.headline)
                                            Image(systemName: "chevron.right")
                                                .font(.headline)
                                        }
                                        .foregroundColor(.brandPrimary)
                                        .frame(width: 100, height: 44) // Minimum touch target
                                    }
                                }
                                
                                // Month Calendar
                                VStack(spacing: 20) {
                                    // Month title without navigation
                                    Text(monthYearString)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.baseWhite)
                                    
                                    // Days of week header
                                    HStack {
                                        ForEach(Array(daysOfWeek.enumerated()), id: \.offset) { index, day in
                                            Text(day)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color.baseWhite.opacity(0.7))
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    
                                    // Calendar grid
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                                        ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                                            if let date = date {
                                                DayCell(date: date, isSelected: isDateInStreak(date))
                                            } else {
                                                Color.clear
                                                    .aspectRatio(1, contentMode: .fill)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            }
                            
                            // Minutes Tracking Chart
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Daily Minutes Goal")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack {
                                    Spacer()
                                    CircularProgressView(
                                        progress: Double(currentMinutes) / Double(dailyGoal),
                                        goal: dailyGoal,
                                        current: currentMinutes
                                    )
                                    .frame(height: 250)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
            .task {
                await loadStreakDays()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private var days: [Date?] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let range = calendar.range(of: .day, in: .month, for: start)!
        
        let firstWeekday = calendar.component(.weekday, from: start)
        let prefixDays = Array(repeating: nil as Date?, count: firstWeekday - 1)
        
        let monthDays = range.map { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: start)!
        }
        
        return prefixDays + monthDays
    }
    
    private func isDateInStreak(_ date: Date) -> Bool {
        return streakDays.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    private func loadStreakDays() async {
        var days: Set<Date> = []
        
        // Add today if we have activity
        if let lastActivity = db.lastActivity,
           calendar.isDateInToday(lastActivity) {
            // Normalize to start of day to ensure proper comparison
            if let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: lastActivity) {
                days.insert(startOfDay)
            }
        }
        
        // Add previous streak days
        if db.currentStreak > 1 {
            let today = Date()
            // Get start of today for consistent date comparisons
            if let startOfToday = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: today) {
                for dayOffset in 1..<db.currentStreak {
                    if let date = calendar.date(byAdding: .day, value: -dayOffset, to: startOfToday) {
                        days.insert(date)
                    }
                }
            }
        }
        
        streakDays = days
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    private let calendar = Calendar.current
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        Text("\(calendar.component(.day, from: date))")
            .font(.system(.body, design: .rounded))
            .fontWeight(isToday ? .bold : .regular)
            .foregroundColor(isToday ? .brandPrimary : .white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(
                Circle()
                    .fill(isSelected ? Color.brandPrimary.opacity(0.2) : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(isToday ? Color.brandPrimary : Color.clear, lineWidth: 1)
                    )
            )
    }
}

#Preview {
    ProgressView()
        .environmentObject(DB())
        .preferredColorScheme(.dark)
}
