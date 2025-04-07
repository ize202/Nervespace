import SwiftUI
import SharedKit
import SupabaseKit

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var db: DB
    @State private var reminderTime: Date?
    @State private var isReminderEnabled: Bool = false
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return "Version \(version)"
    }
    
    private func loadReminderSettings() {
        isReminderEnabled = UserDefaults.standard.bool(forKey: "workout_reminder_enabled")
        reminderTime = UserDefaults.standard.object(forKey: "workout_reminder_time") as? Date
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    // Account Section
                    Section("ACCOUNT") {
                        NavigationLink {
                            AccountSettingsView(db: db)
                        } label: {
                            Text("Account Settings")
                        }
                    }
                    
                    // Settings Section
                    Section("SETTINGS") {
                        NavigationLink {
                            WorkoutReminderView()
                        } label: {
                            HStack {
                                Text("Workout Reminder")
                                Spacer()
                                
                                if isReminderEnabled, let time = reminderTime {
                                    Text(time, style: .time)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    // Support Section
                    Section("SUPPORT") {
                        NavigationLink {
                            Text("Contact Support View")
                        } label: {
                            Text("Contact Support")
                        }
                        
                        NavigationLink {
                            Text("Membership View")
                        } label: {
                            Text("Membership")
                        }
                        
                        NavigationLink {
                            Text("Terms of Use")
                        } label: {
                            Text("Terms of Use")
                        }
                        
                        NavigationLink {
                            Text("Privacy Policy")
                        } label: {
                            Text("Privacy Policy")
                        }
                    }
                }
                
                // App Info Section
                VStack(spacing: 4) {
                    Text(appVersion)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("Made with ♥️")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("© 2025 Slips LLC")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                loadReminderSettings()
                
                // Set up notification observer
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("WorkoutReminderSettingsChanged"),
                    object: nil,
                    queue: .main
                ) { _ in
                    loadReminderSettings()
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(DB())
} 
