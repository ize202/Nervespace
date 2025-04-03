import SwiftUI
import SharedKit
import SupabaseKit

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var db: DB
    
    var body: some View {
        NavigationView {
            List {
                // Account Section
                Section("ACCOUNT") {
                    NavigationLink {
                        AccountSettingsView(db: db)
                    } label: {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color.brandPrimary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(db.currentUser?.email ?? "No Email")
                                    .font(.headline)
                                Text("Sign in with Apple")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 8)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Settings Section
                Section("SETTINGS") {
                    NavigationLink("Notifications") {
                        Text("Notifications Settings")
                    }
                    
                    NavigationLink("Sound") {
                        Text("Sound Settings")
                    }
                    
                    NavigationLink("Appearance") {
                        Text("Appearance Settings")
                    }
                }
                
                // Preferences Section
                Section("PREFERENCES") {
                    NavigationLink("Experience Level") {
                        Text("Experience Level Settings")
                    }
                    
                    NavigationLink("Focus Areas") {
                        Text("Focus Areas Settings")
                    }
                }
                
                // Support Section
                Section {
                    Button(action: {
                        // Add action for redeeming gift card
                    }) {
                        Text("Redeem Gift Card or Code")
                            .foregroundColor(Color.brandPrimary)
                    }
                    
                    Button(action: {
                        // Add action for sending gift card
                    }) {
                        Text("Send Gift Card by Email")
                            .foregroundColor(Color.brandPrimary)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
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
