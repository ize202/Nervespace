import Foundation

public protocol RoutineService {
    func fetchRoutines() async throws -> [Routine]
    func fetchRoutine(id: UUID) async throws -> Routine
    func createRoutine(_ routine: Routine) async throws -> Routine
    func updateRoutine(_ routine: Routine) async throws -> Routine
    func deleteRoutine(id: UUID) async throws
    
    // Routine Exercise methods
    func fetchRoutineExercises(routineId: UUID) async throws -> [RoutineExercise]
    func addExerciseToRoutine(routineId: UUID, exerciseId: UUID, sequenceOrder: Int, duration: Int) async throws -> RoutineExercise
    func updateRoutineExercise(_ routineExercise: RoutineExercise) async throws -> RoutineExercise
    func removeExerciseFromRoutine(routineId: UUID, exerciseId: UUID) async throws
    
    // Premium content
    func fetchPremiumRoutines() async throws -> [Routine]
    func fetchFreeRoutines() async throws -> [Routine]
} 