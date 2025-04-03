import SwiftUI
import SharedKit
import SupabaseKit

struct AccountSettingsView: View {
    @EnvironmentObject private var db: DB
    @StateObject private var viewModel: AccountSettingsViewModel
    @State private var showingNameEmailSheet = false
    @State private var showingDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    init(db: DB) {
        _viewModel = StateObject(wrappedValue: AccountSettingsViewModel(db: db))
    }
    
    var body: some View {
        List {
            // Account Management Section
            Section {
                Button {
                    showingNameEmailSheet = true
                } label: {
                    Text("Change Name & Email")
                        .foregroundColor(.primary)
                }
                
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Text("Delete Account")
                }
                
                Button(role: .destructive) {
                    Task {
                        if await viewModel.signOut() {
                            // Handle successful sign out (e.g., navigate to login screen)
                        }
                    }
                } label: {
                    Text("Log Out")
                }
            }
            
            // Email Display Section
            Section {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Logged in as \(viewModel.userEmail)")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteAccount() {
                        // Handle successful deletion (e.g., navigate to login screen)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .sheet(isPresented: $showingNameEmailSheet) {
            NavigationView {
                ChangeNameEmailView(viewModel: viewModel)
            }
        }
    }
}

struct ChangeNameEmailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AccountSettingsViewModel
    @State private var name: String = ""
    @State private var email: String = ""
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
        .navigationTitle("Change Name & Email")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        if await viewModel.updateProfile(name: name, email: email) {
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .onAppear {
            name = viewModel.userName
            email = viewModel.userEmail
        }
    }
}

#Preview {
    let db = DB()
    return NavigationView {
        AccountSettingsView(db: db)
            .environmentObject(db)
    }
} 
