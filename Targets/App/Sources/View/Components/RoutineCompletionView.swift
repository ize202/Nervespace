import SwiftUI
import SharedKit
import SupabaseKit

struct RoutineCompletionView: View {
    let routine: Routine
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var db: DB
    @State private var isUpdating = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let weekDays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    private let calendar = Calendar.current
    
    private var buttonText: String {
        db.currentStreak <= 1 ? "START STREAK" : "ADD TO STREAK"
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.baseBlack.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 32) {
                // Header Text
                VStack(alignment: .leading, spacing: 8) {
                    Text("Congrats")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("You completed your daily routine.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal)
                
                // Streak Card
                VStack(spacing: 16) {
                    // Streak count
                    Text("\(db.currentStreak) day")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("ACTIVE STREAK")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                    
                    // Week view
                    HStack(spacing: 20) {
                        ForEach(weekDays, id: \.self) { day in
                            VStack(spacing: 8) {
                                Text(day)
                                    .font(.footnote)
                                    .fontWeight(.medium)
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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Completed Routine Card with Checkmark
                HStack(spacing: 16) {
                    // Routine Info
                    HStack(spacing: 16) {
                        // Thumbnail
                        Image(routine.thumbnailName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(routine.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("\(routine.exercises.count) exercises • \(routine.totalDuration / 60) min")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    // Checkmark Icon
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        }
                }
                .padding()
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
                        Text(buttonText)
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
        isUpdating = true
        do {
            try await db.recordCompletion(routine: routine)
            dismiss()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isUpdating = false
    }
}

#Preview {
    RoutineCompletionView(routine: RoutineLibrary.routines.first!)
        .environmentObject(DB())
} 
