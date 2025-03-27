import Foundation
import Supabase

public final class SupabaseRoutineService: RoutineService {
    private let supabase: SupabaseClient
    private let exerciseService: ExerciseService
    
    public init(supabase: SupabaseClient, exerciseService: ExerciseService) {
        self.supabase = supabase
        self.exerciseService = exerciseService
    }
    
    public func fetchRoutines() async throws -> [Routine] {
        try await supabase
            .from("routines")
            .select()
            .execute()
            .value
    }
    
    public func fetchRoutine(id: UUID) async throws -> Routine {
        try await supabase
            .from("routines")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }
    
    public func fetchRoutineExercises(routineId: UUID) async throws -> [RoutineExercise] {
        try await supabase
            .from("routine_exercises")
            .select()
            .eq("routine_id", value: routineId)
            .order("sequence_order")
            .execute()
            .value
    }
    
    public func fetchRoutineWithExercises(id: UUID) async throws -> (Routine, [Exercise]) {
        async let routineTask = fetchRoutine(id: id)
        async let routineExercisesTask = fetchRoutineExercises(routineId: id)
        
        let (routine, routineExercises) = try await (routineTask, routineExercisesTask)
        let exerciseIds = routineExercises.map { $0.exerciseId }
        let exercises = try await exerciseService.fetchExercisesByIds(exerciseIds)
        
        // Sort exercises according to sequence_order
        let sortedExercises = routineExercises
            .sorted { $0.sequenceOrder < $1.sequenceOrder }
            .compactMap { routineExercise in
                exercises.first { $0.id == routineExercise.exerciseId }
            }
        
        return (routine, sortedExercises)
    }
    
    public func fetchRoutinesByIds(_ ids: [UUID]) async throws -> [Routine] {
        try await supabase
            .from("routines")
            .select()
            .in("id", values: ids)
            .execute()
            .value
    }
} 