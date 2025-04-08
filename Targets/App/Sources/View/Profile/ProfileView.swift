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
    
    private func openEmail() {
        if let url = URL(string: "mailto:support@useformapp.com") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openSubscriptions() {
        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
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
                        Button {
                            openEmail()
                        } label: {
                            HStack {
                                Text("Contact Support")
                                Spacer()
                                Image(systemName: "envelope")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button {
                            openSubscriptions()
                        } label: {
                            HStack {
                                Text("Membership")
                                Spacer()
                                Image(systemName: "creditcard")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Link(destination: URL(string: "https://www.useformapp.com/policies/terms")!) {
                            HStack {
                                Text("Terms of Use")
                                Spacer()
                                Image(systemName: "doc.text")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Link(destination: URL(string: "https://www.useformapp.com/policies/privacy")!) {
                            HStack {
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "lock.shield")
                                    .foregroundColor(.secondary)
                            }
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
