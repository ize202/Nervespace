import SwiftUI
import SharedKit
import AuthenticationServices
import Supabase
import SupabaseKit

@MainActor
class AccountSettingsViewModel: ObservableObject {
    @Published var userEmail: String = ""
    @Published var userName: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db: DB
    
    init(db: DB) {
        self.db = db
        Task {
            await loadUserProfile()
        }
    }
    
    func loadUserProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let userId = db.currentUser?.id else {
                errorMessage = "No user logged in"
                return
            }
            
            let profile = try await db.userService.fetchProfile(userId: userId)
            userName = profile.name ?? ""
            userEmail = profile.email ?? ""
            errorMessage = nil
        } catch {
            print("Error loading user profile: \(error)")
            errorMessage = "Failed to load profile"
        }
    }
    
    func updateProfile(name: String, email: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let userId = db.currentUser?.id else {
                errorMessage = "No user logged in"
                return false
            }
            
            let profile = try await db.userService.updateProfile(
                userId: userId,
                name: name,
                email: email,
                avatarURL: nil
            )
            
            // Update local state
            userName = profile.name ?? ""
            userEmail = profile.email ?? ""
            errorMessage = nil
            return true
        } catch {
            print("Error updating profile: \(error)")
            errorMessage = "Failed to update profile"
            return false
        }
    }
    
    func deleteAccount() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let userId = db.currentUser?.id else {
                errorMessage = "No user logged in"
                return false
            }
            
            try await db.userService.deleteProfile(userId: userId)
            try await db.signOut()
            errorMessage = nil
            return true
        } catch {
            print("Error deleting account: \(error)")
            errorMessage = "Failed to delete account"
            return false
        }
    }
    
    func signOut() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await db.signOut()
            errorMessage = nil
            return true
        } catch {
            print("Error signing out: \(error)")
            errorMessage = "Failed to sign out"
            return false
        }
    }
}

// Helper struct to decode user profile from database
private struct UserProfile: Codable {
    let id: UUID
    let apple_id: String
    let email: String?
    let name: String?
    let created_at: Date
    let updated_at: Date
} 