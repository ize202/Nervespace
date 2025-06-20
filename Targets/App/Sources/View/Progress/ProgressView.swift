import SwiftUI
import SharedKit
import SupabaseKit

struct ProgressView: View {
    @StateObject private var viewModel: ProgressViewModel
    @EnvironmentObject private var completionStore: RoutineCompletionStore
    @EnvironmentObject private var syncManager: SupabaseSyncManager
    @EnvironmentObject private var progressStore: LocalProgressStore
    
    private let currentDate = Date()
    @State private var completionDays: Set<Date> = []
    @State private var showingGoalSettings = false
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    init(progressStore: LocalProgressStore, syncManager: SupabaseSyncManager) {
        _viewModel = StateObject(wrappedValue: ProgressViewModel(
            progressStore: progressStore,
            syncManager: syncManager
        ))
    }
    
    private var currentMinutes: Int {
        viewModel.dailyMinutes
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.baseBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
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
                                    Label("\(viewModel.streak)-Day Streak", systemImage: "flame.fill")
                                        .font(.headline)
                                        .foregroundColor(.brandPrimary)
                                    
                                    Spacer()
                                    
                                    NavigationLink(destination: HistoryView(
                                        completionStore: completionStore,
                                        syncManager: syncManager
                                    )) {
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
                                                DayCell(date: date, isSelected: isDateCompleted(date))
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
                                HStack {
                                    Text("Daily Minutes Goal")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showingGoalSettings = true
                                    }) {
                                        Image(systemName: "gear")
                                            .foregroundColor(.brandPrimary)
                                            .font(.headline)
                                    }
                                }
                                
                                VStack {
                                    Spacer()
                                    CircularProgressView(
                                        progress: Double(currentMinutes) / Double(progressStore.dailyGoal),
                                        goal: progressStore.dailyGoal,
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
            .sheet(isPresented: $showingGoalSettings) {
                DailyGoalSettingsView()
            }
            .task {
                await updateCompletionDays()
                await viewModel.syncInBackground()
            }
            .onChange(of: completionStore.completions) { _ in
                Task {
                    await updateCompletionDays()
                }
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
    
    private func isDateCompleted(_ date: Date) -> Bool {
        return completionDays.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
    private func updateCompletionDays() async {
        let recentCompletions = completionStore.getRecentCompletions()
        var days: Set<Date> = []
        
        for completion in recentCompletions {
            if let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: completion.completedAt) {
                days.insert(startOfDay)
            }
        }
        
        completionDays = days
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
    let progressStore = LocalProgressStore()
    let completionStore = RoutineCompletionStore()
    let pendingStore = PendingCompletionStore()
    let db = DB()
    let syncManager = SupabaseSyncManager(
        db: db,
        progressStore: progressStore,
        completionStore: completionStore,
        pendingStore: pendingStore
    )
    
    ProgressView(
        progressStore: progressStore,
        syncManager: syncManager
    )
    .environmentObject(completionStore)
    .environmentObject(syncManager)
    .preferredColorScheme(.dark)
}
