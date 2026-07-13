import LocalDataKit
import SharedKit
import SwiftUI

struct ProgressView: View {
    @EnvironmentObject private var activityStore: LocalActivityStore
    @State private var showingGoalSettings = false

    private let currentDate = Date()
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]

    private var summary: ProgressSummary {
        activityStore.progress
    }

    private var completionDays: [Date] {
        CompletionHistory.sections(
            from: activityStore.completions,
            calendar: calendar,
            rolloverHour: 4
        )
        .map(\.activityDay)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.baseBlack.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
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
                            calendarCard
                            dailyGoalCard
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingGoalSettings) {
                DailyGoalSettingsView()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label(
                    "\(summary.currentStreak)-Day Streak",
                    systemImage: "flame.fill"
                )
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
                    .frame(width: 100, height: 44)
                }
            }

            VStack(spacing: 20) {
                Text(monthYearString)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.baseWhite)

                HStack {
                    ForEach(Array(daysOfWeek.enumerated()), id: \.offset) { _, day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.baseWhite.opacity(0.7))
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 7),
                    spacing: 8
                ) {
                    ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                        if let date {
                            DayCell(
                                date: date,
                                isSelected: isDateCompleted(date)
                            )
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
    }

    private var dailyGoalCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Minutes Goal")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Button {
                    showingGoalSettings = true
                } label: {
                    Image(systemName: "gear")
                        .foregroundColor(.brandPrimary)
                        .font(.headline)
                }
            }

            CircularProgressView(
                progress: Double(summary.minutesToday)
                    / Double(summary.dailyGoalMinutes),
                goal: summary.dailyGoalMinutes,
                current: summary.minutesToday
            )
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }

    private var days: [Date?] {
        guard
            let start = calendar.date(
                from: calendar.dateComponents([.year, .month], from: currentDate)
            ),
            let range = calendar.range(of: .day, in: .month, for: start)
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: start)
        let prefixDays = Array(repeating: nil as Date?, count: firstWeekday - 1)
        let monthDays = range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: start)
        }
        return prefixDays + monthDays
    }

    private func isDateCompleted(_ date: Date) -> Bool {
        completionDays.contains { calendar.isDate($0, inSameDayAs: date) }
    }
}

private struct DayCell: View {
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
                    .fill(isSelected ? Color.brandPrimary.opacity(0.2) : .clear)
                    .overlay {
                        Circle()
                            .stroke(
                                isToday ? Color.brandPrimary : .clear,
                                lineWidth: 1
                            )
                    }
            )
    }
}

#Preview {
    ProgressView()
        .environmentObject(makePreviewActivityStore())
        .preferredColorScheme(.dark)
}
