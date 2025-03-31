import SwiftUI
import SharedKit
import SupabaseKit

struct RoutineCompletionView: View {
    let routine: Routine
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var db: DB
    @StateObject private var progressManager: ProgressManager
    @State private var isUpdating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let weekDays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    private let calendar = Calendar.current
    
    init(routine: Routine) {
        self.routine = routine
        _progressManager = StateObject(wrappedValue: ProgressManager())
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.baseBlack.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Checkmark Icon
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.white)
                    }
                
                // Congratulations Text
                VStack(spacing: 8) {
                    Text("Congrats!")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("You completed your daily routine.")
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Streak Card
                VStack(spacing: 16) {
                    // Streak count
                    Text("\(progressManager.currentStreak) day")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("ACTIVE STREAK")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                    
                    // Week view
                    HStack(spacing: 20) {
                        ForEach(weekDays, id: \.self) { day in
                            VStack(spacing: 8) {
                                Text(day)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Circle()
                                    .fill(isToday(day) ? .white.opacity(0.2) : Color.white.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                    .overlay {
                                        if isToday(day) {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer()
                
                // Add to Streak Button
                Button(action: {
                    Task {
                        await addToStreak()
                    }
                }) {
                    HStack {
                        Text("ADD TO STREAK")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if isUpdating {
                            ProgressView()
                                .tint(.white)
                                .padding(.leading, 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.brandPrimary)
                    .cornerRadius(12)
                }
                .disabled(isUpdating)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top, 64)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func isToday(_ day: String) -> Bool {
        let today = calendar.component(.weekday, from: Date())
        // Convert weekday to our format (Mo = 1, Su = 7)
        let dayIndex = weekDays.firstIndex(of: day)! + 1
        // Convert Sunday from 1 to 7
        let adjustedToday = today == 1 ? 7 : today - 1
        return dayIndex == adjustedToday
    }
    
    private func addToStreak() async {
        guard let userId = db.currentUser?.id else {
            showError = true
            errorMessage = "User not logged in"
            return
        }
        
        isUpdating = true
        do {
            try await progressManager.recordCompletion(userId: userId, routine: routine)
            dismiss()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isUpdating = false
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    RoutineCompletionView(routine: RoutineLibrary.routines.first!)
        .environmentObject(DB())
} 