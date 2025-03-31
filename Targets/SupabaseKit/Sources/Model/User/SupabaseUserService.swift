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
    let dailyMinutes: Int?
    let totalMinutes: Int?
    let lastActivity: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case deviceId = "device_id"
        case streak
        case dailyMinutes = "daily_minutes"
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
    let p_user_id: String?
    let p_device_id: String?
    let p_days: Int
}

private struct InitialProgressParams: Encodable {
    let device_id: UUID
    let streak: Int
    let daily_minutes: Int
    let total_minutes: Int
    let last_activity: Date?
    
    enum CodingKeys: String, CodingKey {
        case device_id
        case streak
        case daily_minutes
        case total_minutes
        case last_activity
    }
}

private struct RecordRoutineCompletionParams: Encodable {
    let p_routine_id: String
    let p_duration_minutes: Int
    let p_user_id: String?
    let p_device_id: String?
}

private struct MigrateProgressParams: Encodable {
    let p_device_id: String
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
    
    public func fetchProgressByDeviceId(_ deviceId: UUID) async throws -> Model.UserProgress {
        let response: Model.UserProgress = try await client
            .from("user_progress")
            .select()
            .eq("device_id", value: deviceId)
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
    
    public func initializeAnonymousProgress(deviceId: UUID) async throws -> Model.UserProgress {
        print("[DB] Initializing anonymous progress with deviceId: \(deviceId)")
        
        let params = InitialProgressParams(
            device_id: deviceId,
            streak: 0,
            daily_minutes: 0,
            total_minutes: 0,
            last_activity: nil
        )
        
        do {
            print("[DB] Sending params to Supabase: \(String(describing: params))")
            let response: Model.UserProgress = try await client
                .from("user_progress")
                .insert(params)
                .single()
                .execute()
                .value
            
            print("[DB] Successfully created anonymous progress: \(String(describing: response))")
            return response
        } catch {
            print("[DB] Error creating anonymous progress: \(error.localizedDescription)")
            throw error
        }
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
            deviceId: nil,
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
    
    public func updateAnonymousProgress(
        deviceId: UUID,
        streak: Int?,
        dailyMinutes: Int?,
        totalMinutes: Int?,
        lastActivity: Date?
    ) async throws -> Model.UserProgress {
        let update = ProgressUpdate(
            userId: nil,
            deviceId: deviceId,
            streak: streak,
            dailyMinutes: dailyMinutes,
            totalMinutes: totalMinutes,
            lastActivity: lastActivity
        )
        
        let response: Model.UserProgress = try await client
            .from("user_progress")
            .update(update)
            .eq("device_id", value: deviceId)
            .single()
            .execute()
            .value
        return response
    }
    
    public func migrateAnonymousProgress(
        from deviceId: UUID,
        to userId: UUID
    ) async throws {
        let params = MigrateProgressParams(
            p_device_id: deviceId.uuidString,
            p_user_id: userId.uuidString
        )
        
        try await client
            .rpc("migrate_anonymous_progress", params: params)
            .execute()
    }
    
    // MARK: - Premium Status
    
    public func updatePremiumStatus(
        userId: UUID,
        isPremium: Bool,
        premiumUntil: Date?
    ) async throws -> Model.UserProfile {
        let update = PremiumStatusUpdate(
            isPremium: isPremium,
            premiumUntil: premiumUntil
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
    
    // MARK: - Utility Methods
    
    public func findProfileByAppleId(_ appleId: String) async throws -> Model.UserProfile? {
        do {
            let response: Model.UserProfile = try await client
                .from("user_profiles")
                .select()
                .eq("apple_id", value: appleId)
                .single()
                .execute()
                .value
            return response
        } catch {
            return nil
        }
    }
    
    public func recordRoutineCompletion(
        routineId: String,
        durationMinutes: Int,
        userId: UUID?,
        deviceId: UUID?
    ) async throws -> UUID {
        let params = RecordRoutineCompletionParams(
            p_routine_id: routineId,
            p_duration_minutes: durationMinutes,
            p_user_id: userId?.uuidString,
            p_device_id: deviceId?.uuidString
        )
        
        let response: UUID = try await client
            .rpc("record_routine_completion", params: params)
            .execute()
            .value
        
        return response
    }
    
    public func getRecentCompletions(
        userId: UUID?,
        deviceId: UUID?,
        days: Int
    ) async throws -> [Model.RoutineCompletion] {
        let params = GetRecentCompletionsParams(
            p_user_id: userId?.uuidString,
            p_device_id: deviceId?.uuidString,
            p_days: days
        )
        
        let response: [Model.RoutineCompletion] = try await client
            .rpc("get_recent_completions", params: params)
            .execute()
            .value
        
        return response
    }
    
    public func getCurrentStreak(userId: UUID) async throws -> Int {
        let query = "user_id.eq.\(userId),device_id.eq.\(userId)"
        
        do {
            let response: [Model.UserProgress] = try await client
                .from("user_progress")
                .select()
                .or(query)
                .execute()
                .value
            
            guard let progress = response.first else {
                throw NSError(domain: "UserService", code: 404, userInfo: [
                    NSLocalizedDescriptionKey: "User progress not found"
                ])
            }
            
            return progress.streak
        } catch {
            // If that fails, try fetching by device ID specifically
            let response: [Model.UserProgress] = try await client
                .from("user_progress")
                .select()
                .eq("device_id", value: userId)
                .execute()
                .value
            
            guard let progress = response.first else {
                throw NSError(domain: "UserService", code: 404, userInfo: [
                    NSLocalizedDescriptionKey: "User progress not found"
                ])
            }
            
            return progress.streak
        }
    }
} 