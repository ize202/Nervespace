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
        let exerciseIds: [UUID] = try await supabase
            .from("exercise_tags")
            .select("exercise_id")
            .eq("tag", value: tag)
            .execute()
            .value
            .compactMap { dict in
                guard let idString = dict["exercise_id"] as? String,
                      let id = UUID(uuidString: idString) else {
                    return nil
                }
                return id
            }
        
        return try await fetchExercisesByIds(exerciseIds)
    }
} 