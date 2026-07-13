import LocalDataKit
import SwiftUI

struct DailyGoalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var activityStore: LocalActivityStore
    @State private var selectedMinutes = 5
    @State private var errorMessage: String?
    
    private let minuteOptions = [5, 10, 15, 20, 30, 45, 60]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(minuteOptions, id: \.self) { minutes in
                        Button(action: {
                            selectedMinutes = minutes
                            do {
                                try activityStore.setDailyGoal(minutes: minutes)
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }) {
                            HStack {
                                Text("\(minutes) minutes")
                                Spacer()
                                if minutes == selectedMinutes {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.brandPrimary)
                                }
                            }
                        }
                        .foregroundColor(.white)
                    }
                } header: {
                    Text("Choose your daily goal")
                }
            }
            .navigationTitle("Daily Minutes Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            selectedMinutes = activityStore.dailyGoalMinutes
        }
        .alert("Unable to Save Goal", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }
}

#Preview {
    DailyGoalSettingsView()
        .environmentObject(makePreviewActivityStore())
}
