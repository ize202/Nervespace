import Foundation
import Supabase

// Update types for encoding
private struct ProfileUpdate: Encodable {
    let name: String?
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case avatarURL = "avatar_url"
    }
}

private struct ProgressUpdate: Encodable {
    let streak: Int?
    let routineCompletions: Int?
    let totalMinutes: Int?
    let lastActivity: Date?
    
    enum CodingKeys: String, CodingKey {
        case streak
        case routineCompletions = "routine_completions"
        case totalMinutes = "total_minutes"
        case lastActivity = "last_activity"
    }
}

private struct PremiumStatusUpdate: Encodable {
    let isPremium: Bool
    let premiumUntil: Date?
    
    enum CodingKeys: String, CodingKey {
        case isPremium = "is_premium"
        case premiumUntil = "premium_until"
    }
}

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
        let update = ProfileUpdate(
            name: name,
            avatarURL: avatarURL?.absoluteString
        )
        
        let profiles: [UserProfile] = try await client.database
            .from("user_profiles")
            .update(update)
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
        let update = ProgressUpdate(
            streak: streak,
            routineCompletions: routineCompletions,
            totalMinutes: totalMinutes,
            lastActivity: lastActivity
        )
        
        let progresses: [UserProgress] = try await client.database
            .from("user_progress")
            .update(update)
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
        let update = PremiumStatusUpdate(
            isPremium: isPremium,
            premiumUntil: premiumUntil
        )
        
        let profiles: [UserProfile] = try await client.database
            .from("user_profiles")
            .update(update)
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