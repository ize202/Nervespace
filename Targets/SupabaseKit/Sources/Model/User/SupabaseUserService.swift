import Foundation
import Supabase

// Update types for encoding
private struct ProfileUpdate: Encodable {
    let name: String?
    let email: String?
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
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
            id: client.auth.currentUser?.id ?? UUID(),
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
    
    public func updateProfile(userId: UUID, name: String?, email: String?, avatarURL: URL?) async throws -> Model.UserProfile {
        let update = ProfileUpdate(
            name: name,
            email: email,
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
        do {
            // Try to fetch existing progress
            let response: Model.UserProgress = try await client
                .from("user_progress")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
                .value
            return response
        } catch let error {
            // Check if the error message contains "multiple (or no) rows returned"
            let errorDescription = error.localizedDescription
            if errorDescription.contains("multiple (or no) rows returned") {
                // No progress record exists, create a new one
                print("[DB] No progress record found, initializing new progress for user \(userId)")
                return try await initializeProgress(userId: userId)
            } else {
                // Re-throw any other errors
                throw error
            }
        }
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
    
    private struct RecordRoutineCompletionParams: Encodable {
        let p_routine_id: String
        let p_duration_minutes: Int
    }
    
    public func recordRoutineCompletion(
        routineId: String,
        durationMinutes: Int,
        userId: UUID
    ) async throws -> UUID {
        let response: UUID = try await client
            .rpc("record_routine_completion", params: [
                "p_routine_id": routineId,
                "p_duration_minutes": String(durationMinutes),
                "p_completed_at": ISO8601DateFormatter().string(from: Date())
            ])
            .execute()
            .value
        
        return response
    }
    
    private struct GetRecentCompletionsParams: Encodable {
        let p_days: Int
    }
    
    public func getRecentCompletions(
        userId: UUID,
        days: Int
    ) async throws -> [Model.RoutineCompletion] {
        let response: [Model.RoutineCompletion] = try await client.database
            .rpc("get_recent_completions", params: [
                "p_days": String(days)
            ])
            .execute()
            .value
        
        return response
    }
    
    public func softDeleteCompletion(completionId: UUID, userId: UUID) async throws {
        try await client.database
            .rpc("soft_delete_completion", params: [
                "p_completion_id": completionId.uuidString
            ])
            .execute()
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
