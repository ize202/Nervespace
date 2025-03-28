import Foundation
import Supabase

public class SupabaseExerciseService: ExerciseService {
    private let client: SupabaseClient
    
    public init(client: SupabaseClient) {
        self.client = client
    }
    
    public func fetchExercises() async throws -> [Exercise] {
        return try await client.database
            .from("exercises")
            .select()
            .execute()
            .value
    }
    
    public func fetchExercise(id: UUID) async throws -> Exercise {
        let exercises: [Exercise] = try await client.database
            .from("exercises")
            .select()
            .eq("id", value: id)
            .execute()
            .value
        
        guard let exercise = exercises.first else {
            throw NSError(domain: "ExerciseService", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Exercise not found"
            ])
        }
        
        return exercise
    }
    
    public func createExercise(_ exercise: Exercise) async throws -> Exercise {
        let exercises: [Exercise] = try await client.database
            .from("exercises")
            .insert(exercise)
            .execute()
            .value
        
        guard let created = exercises.first else {
            throw NSError(domain: "ExerciseService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create exercise"
            ])
        }
        
        return created
    }
    
    public func updateExercise(_ exercise: Exercise) async throws -> Exercise {
        let exercises: [Exercise] = try await client.database
            .from("exercises")
            .update(exercise)
            .eq("id", value: exercise.id)
            .execute()
            .value
        
        guard let updated = exercises.first else {
            throw NSError(domain: "ExerciseService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to update exercise"
            ])
        }
        
        return updated
    }
    
    public func deleteExercise(id: UUID) async throws {
        try await client.database
            .from("exercises")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    public func fetchExercises(byCategory category: ExerciseCategory) async throws -> [Exercise] {
        return try await client.database
            .from("exercises")
            .select()
            .contains("categories", value: [category.rawValue])
            .execute()
            .value
    }
    
    public func fetchExercises(byPosition position: ExercisePosition) async throws -> [Exercise] {
        return try await client.database
            .from("exercises")
            .select()
            .contains("positions", value: [position.rawValue])
            .execute()
            .value
    }
    
    public func fetchExercises(byArea area: ExerciseArea) async throws -> [Exercise] {
        return try await client.database
            .from("exercises")
            .select()
            .contains("areas", value: [area.rawValue])
            .execute()
            .value
    }
    
    public func fetchExercises(
        categories: [ExerciseCategory]?,
        positions: [ExercisePosition]?,
        areas: [ExerciseArea]?
    ) async throws -> [Exercise] {
        var query = client.database
            .from("exercises")
            .select()
        
        if let categories = categories, !categories.isEmpty {
            query = query.contains("categories", value: categories.map { $0.rawValue })
        }
        
        if let positions = positions, !positions.isEmpty {
            query = query.contains("positions", value: positions.map { $0.rawValue })
        }
        
        if let areas = areas, !areas.isEmpty {
            query = query.contains("areas", value: areas.map { $0.rawValue })
        }
        
        return try await query.execute().value
    }
    
    public func fetchExerciseTags(exerciseId: UUID) async throws -> [ExerciseTag] {
        try await client.database
            .from("exercise_tags")
            .select()
            .eq("exercise_id", value: exerciseId)
            .execute()
            .value
    }
    
    public func fetchExercisesByIds(_ ids: [UUID]) async throws -> [Exercise] {
        try await client.database
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
        
        let responses: [ExerciseIdResponse] = try await client.database
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