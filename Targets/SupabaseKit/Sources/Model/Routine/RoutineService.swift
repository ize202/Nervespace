import Foundation

public protocol RoutineService {
    func fetchRoutines() async throws -> [Routine]
    func fetchRoutine(id: UUID) async throws -> Routine
    func fetchRoutineExercises(routineId: UUID) async throws -> [RoutineExercise]
    func fetchRoutineWithExercises(id: UUID) async throws -> (Routine, [Exercise])
    func fetchRoutinesByIds(_ ids: [UUID]) async throws -> [Routine]
} 