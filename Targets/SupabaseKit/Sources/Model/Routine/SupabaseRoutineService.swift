import Foundation
import Supabase

public class SupabaseRoutineService: RoutineService {
    private let client: SupabaseClient
    
    public init(client: SupabaseClient) {
        self.client = client
    }
    
    public func fetchRoutines() async throws -> [Routine] {
        return try await client.database
            .from("routines")
            .select()
            .execute()
            .value
    }
    
    public func fetchRoutine(id: UUID) async throws -> Routine {
        let routines: [Routine] = try await client.database
            .from("routines")
            .select()
            .eq("id", value: id)
            .execute()
            .value
        
        guard let routine = routines.first else {
            throw NSError(domain: "RoutineService", code: 404, userInfo: [
                NSLocalizedDescriptionKey: "Routine not found"
            ])
        }
        
        return routine
    }
    
    public func createRoutine(_ routine: Routine) async throws -> Routine {
        let routines: [Routine] = try await client.database
            .from("routines")
            .insert(routine)
            .execute()
            .value
        
        guard let created = routines.first else {
            throw NSError(domain: "RoutineService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to create routine"
            ])
        }
        
        return created
    }
    
    public func updateRoutine(_ routine: Routine) async throws -> Routine {
        let routines: [Routine] = try await client.database
            .from("routines")
            .update(routine)
            .eq("id", value: routine.id)
            .execute()
            .value
        
        guard let updated = routines.first else {
            throw NSError(domain: "RoutineService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to update routine"
            ])
        }
        
        return updated
    }
    
    public func deleteRoutine(id: UUID) async throws {
        try await client.database
            .from("routines")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    public func fetchRoutineExercises(routineId: UUID) async throws -> [RoutineExercise] {
        return try await client.database
            .from("routine_exercises")
            .select()
            .eq("routine_id", value: routineId)
            .order("sequence_order")
            .execute()
            .value
    }
    
    public func addExerciseToRoutine(
        routineId: UUID,
        exerciseId: UUID,
        sequenceOrder: Int,
        duration: Int
    ) async throws -> RoutineExercise {
        let routineExercise = RoutineExercise(
            routineId: routineId,
            exerciseId: exerciseId,
            sequenceOrder: sequenceOrder,
            duration: duration
        )
        
        let routineExercises: [RoutineExercise] = try await client.database
            .from("routine_exercises")
            .insert(routineExercise)
            .execute()
            .value
        
        guard let created = routineExercises.first else {
            throw NSError(domain: "RoutineService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to add exercise to routine"
            ])
        }
        
        return created
    }
    
    public func updateRoutineExercise(_ routineExercise: RoutineExercise) async throws -> RoutineExercise {
        let routineExercises: [RoutineExercise] = try await client.database
            .from("routine_exercises")
            .update(routineExercise)
            .eq("id", value: routineExercise.id)
            .execute()
            .value
        
        guard let updated = routineExercises.first else {
            throw NSError(domain: "RoutineService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "Failed to update routine exercise"
            ])
        }
        
        return updated
    }
    
    public func removeExerciseFromRoutine(routineId: UUID, exerciseId: UUID) async throws {
        try await client.database
            .from("routine_exercises")
            .delete()
            .eq("routine_id", value: routineId)
            .eq("exercise_id", value: exerciseId)
            .execute()
    }
    
    public func fetchPremiumRoutines() async throws -> [Routine] {
        return try await client.database
            .from("routines")
            .select()
            .eq("is_premium", value: true)
            .execute()
            .value
    }
    
    public func fetchFreeRoutines() async throws -> [Routine] {
        return try await client.database
            .from("routines")
            .select()
            .eq("is_premium", value: false)
            .execute()
            .value
    }
} 