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
                        Text("Notifications Settings")
                    } label: {
                        HStack {
                            Text("Notifications")
                            Spacer()
                        }
                    }
                    
                    NavigationLink {
                        Text("Transition Time Settings")
                    } label: {
                        HStack {
                            Text("Transition Time")
                            Spacer()
                            Text("5 seconds")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        Text("Sound Settings")
                    } label: {
                        HStack {
                            Text("Sound")
                            Spacer()
                            Text("Built-In Speaker")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        Text("Appearance Settings")
                    } label: {
                        HStack {
                            Text("Appearance")
                            Spacer()
                            Text("Automatic")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        Text("Voiceover Settings")
                    } label: {
                        Text("Voiceover")
                    }
                    
                    NavigationLink {
                        Text("Apple Health Settings")
                    } label: {
                        HStack {
                            Text("Apple Health")
                            Spacer()
                            Text("On")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Preferences Section
                Section("PREFERENCES") {
                    NavigationLink {
                        Text("Experience Level Settings")
                    } label: {
                        Text("Experience Level")
                    }
                    
                    NavigationLink {
                        Text("Focus Areas Settings")
                    } label: {
                        Text("Focus Areas")
                    }
                    
                    NavigationLink {
                        Text("Health Conditions Settings")
                    } label: {
                        Text("Health Conditions")
                    }
                    
                    NavigationLink {
                        Text("Caution Areas Settings")
                    } label: {
                        Text("Caution Areas")
                    }
                }
                
                // Support Section
                Section("SUPPORT") {
                    NavigationLink {
                        Text("FAQ")
                    } label: {
                        Text("Frequently Asked Questions")
                    }
                    
                    NavigationLink {
                        Text("Contact Support View")
                    } label: {
                        Text("Contact Support")
                    }
                    
                    NavigationLink {
                        Text("Referral Code View")
                    } label: {
                        Text("Referral Code")
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
                    
                    NavigationLink {
                        Text("Health & Safety")
                    } label: {
                        Text("Health & Safety")
                    }
                }
                
                // App Info Section
                Section {
                    VStack(spacing: 4) {
                        Text(appVersion)
                            .font(.footnote)
                            .foregroundColor(.secondary)
//                        Text("Made with ♥️ in NYC")
//                            .font(.footnote)
//                            .foregroundColor(.secondary)
                        Text("© 2024 Slips LLC")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Profile")
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
