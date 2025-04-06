import SwiftUI
import SharedKit
import SupabaseKit

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var db: DB
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return "Version \(version)"
    }
    
    var body: some View {
        NavigationView {
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
                            
                            if UserDefaults.standard.bool(forKey: "workout_reminder_enabled") {
                                let reminderTime = UserDefaults.standard.object(forKey: "workout_reminder_time") as? Date ?? Date()
                                Text(reminderTime, style: .time)
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
                
                // App Info Section
                Section {
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
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
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
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(DB())
} 
