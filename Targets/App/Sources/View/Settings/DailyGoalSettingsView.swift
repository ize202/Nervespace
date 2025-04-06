import SwiftUI
import SharedKit
import SupabaseKit

struct DailyGoalSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var progressStore: LocalProgressStore
    @State private var selectedMinutes: Int
    
    init() {
        // Initialize selectedMinutes with the current goal
        _selectedMinutes = State(initialValue: LocalProgressStore().dailyGoal)
    }
    
    private let minuteOptions = [5, 10, 15, 20, 30, 45, 60]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(minuteOptions, id: \.self) { minutes in
                        Button(action: {
                            selectedMinutes = minutes
                            progressStore.dailyGoal = minutes
                            dismiss()
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
    }
}

#Preview {
    DailyGoalSettingsView()
        .environmentObject(LocalProgressStore())
} 