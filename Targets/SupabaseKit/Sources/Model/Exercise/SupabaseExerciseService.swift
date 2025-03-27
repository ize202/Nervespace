import Foundation
import Supabase

public final class SupabaseExerciseService: ExerciseService {
    private let supabase: SupabaseClient
    
    public init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    public func fetchExercises() async throws -> [Exercise] {
        try await supabase
            .from("exercises")
            .select()
            .execute()
            .value
    }
    
    public func fetchExercise(id: UUID) async throws -> Exercise {
        try await supabase
            .from("exercises")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }
    
    public func fetchExerciseTags(exerciseId: UUID) async throws -> [ExerciseTag] {
        try await supabase
            .from("exercise_tags")
            .select()
            .eq("exercise_id", value: exerciseId)
            .execute()
            .value
    }
    
    public func fetchExercisesByIds(_ ids: [UUID]) async throws -> [Exercise] {
        try await supabase
            .from("exercises")
            .select()
            .in("id", values: ids)
            .execute()
            .value
    }
    
    public func fetchExercisesByTag(_ tag: String) async throws -> [Exercise] {
        // Create a struct to represent the response data
        struct ExerciseIdResponse: Decodable {
            let exercise_id: String
        }
        
        let responses: [ExerciseIdResponse] = try await supabase
            .from("exercise_tags")
            .select("exercise_id")
            .eq("tag", value: tag)
            .execute()
            .value
        
        let exerciseIds = responses.compactMap { UUID(uuidString: $0.exercise_id) }
        
        if exerciseIds.isEmpty {
            return []
        }
        
        return try await fetchExercisesByIds(exerciseIds)
    }
} 