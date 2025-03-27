import Foundation

public protocol ExerciseService {
    func fetchExercises() async throws -> [Exercise]
    func fetchExercise(id: UUID) async throws -> Exercise
    func fetchExerciseTags(exerciseId: UUID) async throws -> [ExerciseTag]
    func fetchExercisesByIds(_ ids: [UUID]) async throws -> [Exercise]
    func fetchExercisesByTag(_ tag: String) async throws -> [Exercise]
} 