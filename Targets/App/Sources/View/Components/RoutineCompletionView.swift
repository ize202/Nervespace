import SwiftUI
import SharedKit

struct RoutineCompletionView: View {
    let routine: Routine
    @Environment(\.dismiss) private var dismiss
    @State private var showingNextStep = false
    
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
                
                // Stats Cards
                VStack(spacing: 12) {
                    StatCard(title: "Exercises", value: "\(routine.exercises.count)")
                    StatCard(title: "Minutes", value: "\(routine.totalDuration / 60)")
                    StatCard(title: "Days Completed", value: "1")
                }
                .padding(.top, 16)
                
                Spacer()
                
                // Add to Streak Button
                Button(action: {
                    showingNextStep = true
                }) {
                    Text("ADD TO STREAK")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top, 64)
        }
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
} 