import Foundation

public protocol ExerciseService {
    func fetchExercises() async throws -> [Exercise]
    func fetchExercise(id: UUID) async throws -> Exercise
    func createExercise(_ exercise: Exercise) async throws -> Exercise
    func updateExercise(_ exercise: Exercise) async throws -> Exercise
    func deleteExercise(id: UUID) async throws
    
    // Category-based queries
    func fetchExercises(byCategory category: ExerciseCategory) async throws -> [Exercise]
    func fetchExercises(byPosition position: ExercisePosition) async throws -> [Exercise]
    func fetchExercises(byArea area: ExerciseArea) async throws -> [Exercise]
    
    // Multi-filter queries
    func fetchExercises(
        categories: [ExerciseCategory]?,
        positions: [ExercisePosition]?,
        areas: [ExerciseArea]?
    ) async throws -> [Exercise]
} 