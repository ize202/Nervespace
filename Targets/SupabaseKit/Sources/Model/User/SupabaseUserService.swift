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
    let userId: UUID?
    let deviceId: UUID?
    let streak: Int?
    let routineCompletions: Int?
    let totalMinutes: Int?
    let lastActivity: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case deviceId = "device_id"
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

private struct RoutineCompletionParams: Encodable {
    let p_routine_id: String
    let p_user_id: String?
    let p_device_id: String?
}

private struct GetRecentCompletionsParams: Encodable {
    let p_start_date: String
    let p_end_date: String
    let p_user_id: String?
    let p_device_id: String?
}

public class SupabaseUserService: UserService {
    private let client: SupabaseClient
    
    public init(client: SupabaseClient) {
        self.client = client
    }
    
    // MARK: - Profile Management
    
    public func fetchProfile(userId: UUID) async throws -> UserProfile {
        let profiles: [UserProfile] = try await client
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
        
        let profiles: [UserProfile] = try await client
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
        
        let profiles: [UserProfile] = try await client
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
        try await client
            .from("user_profiles")
            .delete()
            .eq("id", value: userId)
            .execute()
    }
    
    // MARK: - Progress Tracking
    
    public func fetchProgress(userId: UUID) async throws -> UserProgress {
        let progresses: [UserProgress] = try await client
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
    
    public func fetchProgressByDeviceId(_ deviceId: UUID) async throws -> UserProgress {
        let progresses: [UserProgress] = try await client
            .from("user_progress")
            .select()
            .eq("device_id", value: deviceId)
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
        
        let progresses: [UserProgress] = try await client
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
    
    public func initializeAnonymousProgress(deviceId: UUID) async throws -> UserProgress {
        let progress = UserProgress(deviceId: deviceId)
        
        let progresses: [UserProgress] = try await client
            .from("user_progress")
            .insert(progress)
            .execute()
            .value
        
        guard let created = progresses.first else {
            throw NSError(domain: "UserService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to initialize anonymous progress"
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
            userId: userId,
            deviceId: nil,
            streak: streak,
            routineCompletions: routineCompletions,
            totalMinutes: totalMinutes,
            lastActivity: lastActivity
        )
        
        let progresses: [UserProgress] = try await client
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
    
    public func updateAnonymousProgress(
        deviceId: UUID,
        streak: Int?,
        routineCompletions: Int?,
        totalMinutes: Int?,
        lastActivity: Date?
    ) async throws -> UserProgress {
        let update = ProgressUpdate(
            userId: nil,
            deviceId: deviceId,
            streak: streak,
            routineCompletions: routineCompletions,
            totalMinutes: totalMinutes,
            lastActivity: lastActivity
        )
        
        let progresses: [UserProgress] = try await client
            .from("user_progress")
            .update(update)
            .eq("device_id", value: deviceId)
            .execute()
            .value
        
        guard let updated = progresses.first else {
            throw NSError(domain: "UserService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to update anonymous progress"
            ])
        }
        
        return updated
    }
    
    public func migrateAnonymousProgress(from deviceId: UUID, to userId: UUID) async throws -> UserProgress {
        // First, fetch the anonymous progress
        let anonymousProgress = try await fetchProgressByDeviceId(deviceId)
        
        // Create a new progress entry for the authenticated user
        let update = ProgressUpdate(
            userId: userId,
            deviceId: nil,
            streak: anonymousProgress.streak,
            routineCompletions: anonymousProgress.routineCompletions,
            totalMinutes: anonymousProgress.totalMinutes,
            lastActivity: anonymousProgress.lastActivity
        )
        
        // Insert the new progress
        let progresses: [UserProgress] = try await client
            .from("user_progress")
            .insert(update)
            .execute()
            .value
        
        guard let created = progresses.first else {
            throw NSError(domain: "UserService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to migrate anonymous progress"
            ])
        }
        
        // Delete the anonymous progress
        try await client
            .from("user_progress")
            .delete()
            .eq("device_id", value: deviceId)
            .execute()
        
        return created
    }
    
    // MARK: - Premium Status
    
    public func updatePremiumStatus(userId: UUID, isPremium: Bool, premiumUntil: Date?) async throws -> UserProfile {
        let update = PremiumStatusUpdate(
            isPremium: isPremium,
            premiumUntil: premiumUntil
        )
        
        let profiles: [UserProfile] = try await client
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
        let profiles: [UserProfile] = try await client
            .from("user_profiles")
            .select()
            .eq("apple_id", value: appleId)
            .execute()
            .value
        
        return profiles.first
    }
    
    public func recordRoutineCompletion(
        routineId: String,
        userId: UUID?,
        deviceId: UUID?
    ) async throws -> UUID {
        let params = RoutineCompletionParams(
            p_routine_id: routineId,
            p_user_id: userId?.uuidString,
            p_device_id: deviceId?.uuidString
        )
        
        let result: [String] = try await client
            .rpc("record_routine_completion", params: params)
            .execute()
            .value
        
        guard let completionIdString = result.first,
              let completionId = UUID(uuidString: completionIdString) else {
            throw NSError(domain: "UserService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to record routine completion"
            ])
        }
        
        return completionId
    }
    
    public func getRecentCompletions(
        userId: UUID?,
        deviceId: UUID?,
        days: Int
    ) async throws -> [RoutineCompletion] {
        let startDate = Calendar.current.date(
            byAdding: .day,
            value: -days,
            to: Date()
        ) ?? Date()
        
        let dateFormatter = ISO8601DateFormatter()
        let params = GetRecentCompletionsParams(
            p_start_date: dateFormatter.string(from: startDate),
            p_end_date: dateFormatter.string(from: Date()),
            p_user_id: userId?.uuidString,
            p_device_id: deviceId?.uuidString
        )
        
        let completions: [RoutineCompletion] = try await client
            .rpc("get_user_completions", params: params)
            .execute()
            .value
        
        return completions
    }
    
    public func getCurrentStreak(userId: UUID) async throws -> Int {
        let progresses: [UserProgress] = try await client
            .from("user_progress")
            .select()
            .eq(UserProgress.CodingKeys.userId.rawValue, value: userId)
            .execute()
            .value
        
        guard let progress = progresses.first else {
            throw NSError(domain: "UserService", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "User progress not found"
            ])
        }
        
        return progress.streak
    }
} 