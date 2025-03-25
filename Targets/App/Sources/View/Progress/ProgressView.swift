import SwiftUI
import SharedKit

struct ProgressView: View {
    @State private var selectedDate = Date()
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
                                .foregroundColor(.brandPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                // History action
                            }) {
                                Text("History")
                                    .font(.subheadline)
                                    .foregroundColor(.brandPrimary)
                            }
                        }
                        
                        // Month Calendar
                        VStack(spacing: 20) {
                            // Month Navigation
                            HStack {
                                Button(action: { previousMonth() }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.brandPrimary)
                                }
                                
                                Spacer()
                                
                                Text(monthYearString)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Button(action: { nextMonth() }) {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.brandPrimary)
                                }
                            }
                            
                            // Days of week header
                            HStack {
                                ForEach(daysOfWeek, id: \.self) { day in
                                    Text(day)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
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
                    .background(Color.baseWhite)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    
                    // Minutes Tracking Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Minutes Tracking")
                            .font(.headline)
                            .foregroundColor(.brandPrimary)
                        
                        Rectangle()
                            .fill(Color.baseGray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Text("Daily Activity Chart")
                                    .foregroundColor(.gray)
                            )
                    }
                    .padding()
                    .background(Color.baseWhite)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle("Progress")
            .background(Color.baseGray.opacity(0.1))
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var days: [Date?] {
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
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
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
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
            .foregroundColor(isToday ? .brandPrimary : .primary)
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
} 