import Foundation
import Supabase

public final class SupabaseUserService: UserService {
    private let supabase: SupabaseClient
    
    public init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    public func fetchProfile(userId: UUID) async throws -> UserProfile {
        try await supabase
            .from("user_profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
    }
    
    public func updateProfile(userId: UUID, firstName: String?, lastName: String?) async throws -> UserProfile {
        // Create a struct to represent the update data
        struct ProfileUpdate: Encodable {
            let first_name: String?
            let last_name: String?
        }
        
        let update = ProfileUpdate(first_name: firstName, last_name: lastName)
        
        return try await supabase
            .from("user_profiles")
            .update(update)
            .eq("id", value: userId)
            .single()
            .execute()
            .value
    }
    
    public func fetchProgress(userId: UUID) async throws -> [UserProgress] {
        try await supabase
            .from("user_progress")
            .select()
            .eq("user_id", value: userId)
            .order("completed_at", ascending: false)
            .execute()
            .value
    }
    
    public func recordProgress(userId: UUID, exerciseId: UUID?, routineId: UUID?, duration: Int) async throws -> UserProgress {
        // Create a struct to represent the insert data
        struct ProgressInsert: Encodable {
            let user_id: UUID
            let exercise_id: UUID?
            let routine_id: UUID?
            let duration: Int
        }
        
        let insert = ProgressInsert(
            user_id: userId,
            exercise_id: exerciseId,
            routine_id: routineId,
            duration: duration
        )
        
        return try await supabase
            .from("user_progress")
            .insert(insert)
            .single()
            .execute()
            .value
    }
    
    public func fetchProgressForExercise(userId: UUID, exerciseId: UUID) async throws -> [UserProgress] {
        try await supabase
            .from("user_progress")
            .select()
            .eq("user_id", value: userId)
            .eq("exercise_id", value: exerciseId)
            .order("completed_at", ascending: false)
            .execute()
            .value
    }
    
    public func fetchProgressForRoutine(userId: UUID, routineId: UUID) async throws -> [UserProgress] {
        try await supabase
            .from("user_progress")
            .select()
            .eq("user_id", value: userId)
            .eq("routine_id", value: routineId)
            .order("completed_at", ascending: false)
            .execute()
            .value
    }
} 