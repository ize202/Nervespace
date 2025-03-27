import Foundation

public protocol UserService {
    func fetchProfile(userId: UUID) async throws -> UserProfile
    func updateProfile(userId: UUID, firstName: String?, lastName: String?) async throws -> UserProfile
    func fetchProgress(userId: UUID) async throws -> [UserProgress]
    func recordProgress(userId: UUID, exerciseId: UUID?, routineId: UUID?, duration: Int) async throws -> UserProgress
    func fetchProgressForExercise(userId: UUID, exerciseId: UUID) async throws -> [UserProgress]
    func fetchProgressForRoutine(userId: UUID, routineId: UUID) async throws -> [UserProgress]
} 