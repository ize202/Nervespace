import Foundation
import Supabase

public class SupabaseUserService: UserService {
    private let client: SupabaseClient
    
    public init(client: SupabaseClient) {
        self.client = client
    }
    
    // MARK: - Profile Management
    
    public func fetchProfile(userId: UUID) async throws -> UserProfile {
        let profiles: [UserProfile] = try await client.database
            .from("user_profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        guard let profile = profiles.first else {
            throw NSError(domain: "UserService", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "User profile not found"
            ])
        }
        
        return profile
    }
    
    public func createProfile(appleId: String, email: String?, name: String?) async throws -> UserProfile {
        let profile = UserProfile(
            appleId: appleId,
            email: email,
            name: name
        )
        
        let profiles: [UserProfile] = try await client.database
            .from("user_profiles")
            .insert(profile)
            .execute()
            .value
        
        guard let created = profiles.first else {
            throw NSError(domain: "UserService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create user profile"
            ])
        }
        
        // Initialize progress for the new user
        _ = try await initializeProgress(userId: created.id)
        
        return created
    }
    
    public func updateProfile(userId: UUID, name: String?, avatarURL: URL?) async throws -> UserProfile {
        var updates: [String: Any] = [:]
        if let name = name { updates["name"] = name }
        if let avatarURL = avatarURL { updates["avatar_url"] = avatarURL.absoluteString }
        
        let profiles: [UserProfile] = try await client.database
            .from("user_profiles")
            .update(updates)
            .eq("id", value: userId)
            .execute()
            .value
        
        guard let updated = profiles.first else {
            throw NSError(domain: "UserService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to update user profile"
            ])
        }
        
        return updated
    }
    
    public func deleteProfile(userId: UUID) async throws {
        try await client.database
            .from("user_profiles")
            .delete()
            .eq("id", value: userId)
            .execute()
    }
    
    // MARK: - Progress Tracking
    
    public func fetchProgress(userId: UUID) async throws -> UserProgress {
        let progresses: [UserProgress] = try await client.database
            .from("user_progress")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        guard let progress = progresses.first else {
            throw NSError(domain: "UserService", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "User progress not found"
            ])
        }
        
        return progress
    }
    
    public func initializeProgress(userId: UUID) async throws -> UserProgress {
        let progress = UserProgress(userId: userId)
        
        let progresses: [UserProgress] = try await client.database
            .from("user_progress")
            .insert(progress)
            .execute()
            .value
        
        guard let created = progresses.first else {
            throw NSError(domain: "UserService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to initialize user progress"
            ])
        }
        
        return created
    }
    
    public func updateProgress(
        userId: UUID,
        streak: Int?,
        routineCompletions: Int?,
        totalMinutes: Int?,
        lastActivity: Date?
    ) async throws -> UserProgress {
        var updates: [String: Any] = [:]
        if let streak = streak { updates["streak"] = streak }
        if let routineCompletions = routineCompletions { updates["routine_completions"] = routineCompletions }
        if let totalMinutes = totalMinutes { updates["total_minutes"] = totalMinutes }
        if let lastActivity = lastActivity { updates["last_activity"] = lastActivity }
        
        let progresses: [UserProgress] = try await client.database
            .from("user_progress")
            .update(updates)
            .eq("user_id", value: userId)
            .execute()
            .value
        
        guard let updated = progresses.first else {
            throw NSError(domain: "UserService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to update user progress"
            ])
        }
        
        return updated
    }
    
    // MARK: - Premium Status
    
    public func updatePremiumStatus(userId: UUID, isPremium: Bool, premiumUntil: Date?) async throws -> UserProfile {
        var updates: [String: Any] = ["is_premium": isPremium]
        if let premiumUntil = premiumUntil {
            updates["premium_until"] = premiumUntil
        }
        
        let profiles: [UserProfile] = try await client.database
            .from("user_profiles")
            .update(updates)
            .eq("id", value: userId)
            .execute()
            .value
        
        guard let updated = profiles.first else {
            throw NSError(domain: "UserService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to update premium status"
            ])
        }
        
        return updated
    }
    
    // MARK: - Utility Methods
    
    public func findProfileByAppleId(_ appleId: String) async throws -> UserProfile? {
        let profiles: [UserProfile] = try await client.database
            .from("user_profiles")
            .select()
            .eq("apple_id", value: appleId)
            .execute()
            .value
        
        return profiles.first
    }
} 