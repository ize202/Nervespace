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
    let userId: UUID
    let streak: Int?
    let dailyMinutes: Int?
    let totalMinutes: Int?
    let lastActivity: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case streak
        case dailyMinutes = "daily_minutes"
        case totalMinutes = "total_minutes"
        case lastActivity = "last_activity"
    }
}

private struct RecordRoutineCompletionParams: Encodable {
    let p_routine_id: String
    let p_duration_minutes: Int
    let p_user_id: String
}

public class SupabaseUserService: UserService {
    private let client: SupabaseClient
    
    public init(client: SupabaseClient) {
        self.client = client
    }
    
    // MARK: - Profile Management
    
    public func fetchProfile(userId: UUID) async throws -> Model.UserProfile {
        let response: Model.UserProfile = try await client
            .from("user_profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        return response
    }
    
    public func createProfile(appleId: String, email: String?, name: String?) async throws -> Model.UserProfile {
        let profile = Model.UserProfile(
            appleId: appleId,
            email: email,
            name: name
        )
        
        let response: Model.UserProfile = try await client
            .from("user_profiles")
            .insert(profile)
            .single()
            .execute()
            .value
        return response
    }
    
    public func updateProfile(userId: UUID, name: String?, avatarURL: URL?) async throws -> Model.UserProfile {
        let update = ProfileUpdate(
            name: name,
            avatarURL: avatarURL?.absoluteString
        )
        
        let response: Model.UserProfile = try await client
            .from("user_profiles")
            .update(update)
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        return response
    }
    
    public func deleteProfile(userId: UUID) async throws {
        try await client
            .from("user_profiles")
            .delete()
            .eq("id", value: userId)
            .execute()
    }
    
    // MARK: - Progress Tracking
    
    public func fetchProgress(userId: UUID) async throws -> Model.UserProgress {
        let response: Model.UserProgress = try await client
            .from("user_progress")
            .select()
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        return response
    }
    
    public func initializeProgress(userId: UUID) async throws -> Model.UserProgress {
        let progress = Model.UserProgress(userId: userId)
        
        let response: Model.UserProgress = try await client
            .from("user_progress")
            .insert(progress)
            .single()
            .execute()
            .value
        return response
    }
    
    public func updateProgress(
        userId: UUID,
        streak: Int?,
        dailyMinutes: Int?,
        totalMinutes: Int?,
        lastActivity: Date?
    ) async throws -> Model.UserProgress {
        let update = ProgressUpdate(
            userId: userId,
            streak: streak,
            dailyMinutes: dailyMinutes,
            totalMinutes: totalMinutes,
            lastActivity: lastActivity
        )
        
        let response: Model.UserProgress = try await client
            .from("user_progress")
            .update(update)
            .eq("user_id", value: userId)
            .single()
            .execute()
            .value
        return response
    }
    
    // MARK: - Routine Completions
    
    public func recordRoutineCompletion(
        routineId: String,
        durationMinutes: Int,
        userId: UUID
    ) async throws -> UUID {
        let params = RecordRoutineCompletionParams(
            p_routine_id: routineId,
            p_duration_minutes: durationMinutes,
            p_user_id: userId.uuidString
        )
        
        let response: UUID = try await client
            .rpc("record_routine_completion", params: params)
            .execute()
            .value
        
        return response
    }
    
    public func getRecentCompletions(
        userId: UUID,
        days: Int
    ) async throws -> [Model.RoutineCompletion] {
        let response: [Model.RoutineCompletion] = try await client
            .rpc("get_recent_completions", params: ["p_days": days])
            .execute()
            .value
        return response
    }
    
    // MARK: - Utility Methods
    
    public func findProfileByAppleId(_ appleId: String) async throws -> Model.UserProfile? {
        let response: Model.UserProfile? = try? await client
            .from("user_profiles")
            .select()
            .eq("apple_id", value: appleId)
            .single()
            .execute()
            .value
        return response
    }
} 