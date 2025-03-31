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

private struct InitialProgressParams: Encodable {
    let device_id: UUID
    let streak: Int
    let routine_completions: Int
    let total_minutes: Int
    let last_activity: Date?
    
    enum CodingKeys: String, CodingKey {
        case device_id
        case streak
        case routine_completions = "routine_completions"
        case total_minutes = "total_minutes"
        case last_activity = "last_activity"
    }
}

public class SupabaseUserService: UserService {
    private let client: SupabaseClient
    
    public init(client: SupabaseClient) {
        self.client = client
    }
    
    // MARK: - Profile Management
    
    public func fetchProfile(userId: UUID) async throws -> Model.UserProfile {
        let query = client.database
            .from("user_profiles")
            .select()
            .eq("id", value: userId)
            .single()
        
        let response = try await query.execute()
        let data = try response.decode(Model.UserProfile.self, using: .snakeCase)
        return data
    }
    
    public func createProfile(appleId: String, email: String?, name: String?) async throws -> Model.UserProfile {
        let profile = Model.UserProfile(
            appleId: appleId,
            email: email,
            name: name
        )
        
        let query = client.database
            .from("user_profiles")
            .insert(profile)
            .single()
        
        let response = try await query.execute()
        let data = try response.decode(Model.UserProfile.self, using: .snakeCase)
        return data
    }
    
    public func updateProfile(userId: UUID, name: String?, avatarURL: URL?) async throws -> Model.UserProfile {
        let update = ProfileUpdate(
            name: name,
            avatarURL: avatarURL?.absoluteString
        )
        
        let query = client.database
            .from("user_profiles")
            .update(update)
            .eq("id", value: userId)
            .single()
        
        let response = try await query.execute()
        let data = try response.decode(Model.UserProfile.self, using: .snakeCase)
        return data
    }
    
    public func deleteProfile(userId: UUID) async throws {
        try await client.database
            .from("user_profiles")
            .delete()
            .eq("id", value: userId)
            .execute()
    }
    
    // MARK: - Progress Tracking
    
    public func fetchProgress(userId: UUID) async throws -> Model.UserProgress {
        let query = client.database
            .from("user_progress")
            .select()
            .eq("user_id", value: userId)
            .single()
        
        let response = try await query.execute()
        let data = try response.decode(Model.UserProgress.self, using: .snakeCase)
        return data
    }
    
    public func fetchProgressByDeviceId(_ deviceId: UUID) async throws -> Model.UserProgress {
        let query = client.database
            .from("user_progress")
            .select()
            .eq("device_id", value: deviceId)
            .single()
        
        let response = try await query.execute()
        let data = try response.decode(Model.UserProgress.self, using: .snakeCase)
        return data
    }
    
    public func initializeProgress(userId: UUID) async throws -> Model.UserProgress {
        let progress = Model.UserProgress(userId: userId)
        
        let progresses: [Model.UserProgress] = try await client
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
    
    public func initializeAnonymousProgress(deviceId: UUID) async throws -> Model.UserProgress {
        print("[DB] Initializing anonymous progress with deviceId: \(deviceId)")
        
        // Create minimal params for initialization
        let params = InitialProgressParams(
            device_id: deviceId,
            streak: 0,
            routine_completions: 0,
            total_minutes: 0,
            last_activity: nil
        )
        
        do {
            print("[DB] Sending params to Supabase: \(String(describing: params))")
            let progresses: [Model.UserProgress] = try await client
                .from("user_progress")
                .insert(params)
                .execute()
                .value
            
            guard let created = progresses.first else {
                print("[DB] No progress returned from Supabase")
                throw NSError(domain: "UserService", code: 500, userInfo: [
                    NSLocalizedDescriptionKey: "Failed to initialize anonymous progress"
                ])
            }
            
            print("[DB] Successfully created anonymous progress: \(String(describing: created))")
            return created
        } catch {
            print("[DB] Error creating anonymous progress: \(error.localizedDescription)")
            throw error
        }
    }
    
    public func updateProgress(
        userId: UUID,
        streak: Int?,
        routineCompletions: Int?,
        totalMinutes: Int?,
        lastActivity: Date?
    ) async throws -> Model.UserProgress {
        let update = ProgressUpdate(
            userId: userId,
            deviceId: nil,
            streak: streak,
            routineCompletions: routineCompletions,
            totalMinutes: totalMinutes,
            lastActivity: lastActivity
        )
        
        let progresses: [Model.UserProgress] = try await client
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
    ) async throws -> Model.UserProgress {
        let update = ProgressUpdate(
            userId: nil,
            deviceId: deviceId,
            streak: streak,
            routineCompletions: routineCompletions,
            totalMinutes: totalMinutes,
            lastActivity: lastActivity
        )
        
        let progresses: [Model.UserProgress] = try await client
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
    
    public func migrateAnonymousProgress(
        from deviceId: UUID,
        to userId: UUID
    ) async throws {
        // First, update the user_progress entry
        try await client.database
            .from("user_progress")
            .update([
                "user_id": userId,
                "device_id": nil
            ])
            .eq("device_id", value: deviceId)
            .execute()
        
        // Then, update all routine_completions
        try await client.database
            .from("routine_completions")
            .update([
                "user_id": userId,
                "device_id": nil
            ])
            .eq("device_id", value: deviceId)
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
        
        let query = client.database
            .from("user_profiles")
            .update(update)
            .eq("id", value: userId)
            .single()
        
        let response = try await query.execute()
        let data = try response.decode(Model.UserProfile.self, using: .snakeCase)
        return data
    }
    
    // MARK: - Utility Methods
    
    public func findProfileByAppleId(_ appleId: String) async throws -> Model.UserProfile? {
        let query = client.database
            .from("user_profiles")
            .select()
            .eq("apple_id", value: appleId)
            .single()
        
        do {
            let response = try await query.execute()
            let data = try response.decode(Model.UserProfile.self, using: .snakeCase)
            return data
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
        let query = client.database
            .rpc("record_routine_completion", params: [
                "p_routine_id": routineId,
                "p_duration_minutes": durationMinutes,
                "p_user_id": userId as Any,
                "p_device_id": deviceId as Any
            ])
        
        let response = try await query.execute()
        guard let completionId = try? response.decode(UUID.self) else {
            throw NSError(domain: "UserService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to decode completion ID"
            ])
        }
        return completionId
    }
    
    public func getRecentCompletions(
        userId: UUID?,
        deviceId: UUID?,
        days: Int
    ) async throws -> [Model.RoutineCompletion] {
        let query = client.database
            .rpc("get_recent_completions", params: [
                "p_user_id": userId as Any,
                "p_device_id": deviceId as Any,
                "p_days": days
            ])
        
        let response = try await query.execute()
        let completions = try response.decode([Model.RoutineCompletion].self, using: .snakeCase)
        return completions
    }
    
    public func getCurrentStreak(userId: UUID) async throws -> Int {
        let progresses: [Model.UserProgress]
        
        // Try to fetch progress based on whether this is a user ID or device ID
        do {
            progresses = try await client
                .from("user_progress")
                .select()
                .or("user_id.eq.\(userId),device_id.eq.\(userId)")
                .execute()
                .value
        } catch {
            // If that fails, try fetching by device ID specifically
            progresses = try await client
                .from("user_progress")
                .select()
                .eq("device_id", value: userId)
                .execute()
                .value
        }
        
        guard let progress = progresses.first else {
            throw NSError(domain: "UserService", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "User progress not found"
            ])
        }
        
        return progress.streak
    }
} 