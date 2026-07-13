import LocalDataKit
import SharedKit
import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reminderTime: Date?
    @State private var isReminderEnabled = false

    private var copyrightYear: String {
        String(Calendar.current.component(.year, from: Date()))
    }

    var body: some View {
        NavigationStack {
            List {
                Section("SETTINGS") {
                    NavigationLink {
                        WorkoutReminderView()
                    } label: {
                        HStack {
                            Text("Workout Reminder")
                            Spacer()
                            if isReminderEnabled, let reminderTime {
                                Text(reminderTime, style: .time)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    NavigationLink {
                        DailyGoalSettingsView()
                    } label: {
                        Text("Daily Minutes Goal")
                    }
                }

                Section("ABOUT") {
                    LabeledContent("App", value: Constants.AppData.appName)
                    Text("Short guided routines for stretching, breathing, and resetting.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                    .labelStyle(.iconOnly)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 4) {
                    Text("Version \(Constants.AppData.appVersion)")
                    Text("© \(copyrightYear) \(Constants.AppData.developerName)")
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.bar)
            }
            .onAppear(perform: loadReminderSettings)
            .onReceive(
                NotificationCenter.default.publisher(
                    for: WorkoutReminderSettings.changed
                )
            ) { _ in
                loadReminderSettings()
            }
        }
    }

    private func loadReminderSettings() {
        isReminderEnabled = WorkoutReminderSettings.isEnabled
        reminderTime = WorkoutReminderSettings.time
    }
}

#Preview {
    ProfileView()
        .environmentObject(makePreviewActivityStore())
}
