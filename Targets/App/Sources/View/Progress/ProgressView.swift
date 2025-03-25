import SwiftUI
import SharedKit

struct ProgressView: View {
    // Remove selectedDate since we're always showing current month
    private let currentDate = Date()
    @State private var streakDays: Set<Date> = [Date()]  // Temporary for demo
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Calendar Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Label("4-Day Streak", systemImage: "flame.fill")
                                .font(.headline)
                                .foregroundColor(.brandSecondary)
                            
                            Spacer()
                            
                            Button(action: {
                                // History action
                            }) {
                                HStack(spacing: 4) {
                                    Text("History")
                                        .font(.subheadline)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                .foregroundColor(.brandSecondary)
                            }
                        }
                        
                        // Month Calendar
                        VStack(spacing: 20) {
                            // Month title without navigation
                            Text(monthYearString)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.baseBlack)
                            
                            // Days of week header
                            HStack {
                                ForEach(daysOfWeek, id: \.self) { day in
                                    Text(day)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.baseBlack)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            
                            // Calendar grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                                ForEach(days, id: \.self) { date in
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
                    .background(Color.baseGray)
                    .cornerRadius(16)
                    
                    // Minutes Tracking Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Minutes Tracking")
                            .font(.headline)
                            .foregroundColor(.baseBlack)
                        
                        Rectangle()
                            .fill(Color.baseBlack.opacity(0.1))
                            .frame(height: 200)
                            .overlay(
                                Text("Daily Activity Chart")
                                    .foregroundColor(.baseBlack.opacity(0.5))
                            )
                    }
                    .padding()
                    .background(Color.baseGray)
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
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
            .foregroundColor(isToday ? .brandSecondary : .baseBlack)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(
                Circle()
                    .fill(isSelected ? Color.brandSecondary.opacity(0.2) : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(isToday ? Color.brandSecondary : Color.clear, lineWidth: 1)
                    )
            )
    }
}

#Preview {
    ProgressView()
} 