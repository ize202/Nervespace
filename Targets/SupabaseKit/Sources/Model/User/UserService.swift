import Foundation

public protocol UserService {
    // Profile management
    func fetchProfile(userId: UUID) async throws -> UserProfile
    func createProfile(appleId: String, email: String?, name: String?) async throws -> UserProfile
    func updateProfile(userId: UUID, name: String?, avatarURL: URL?) async throws -> UserProfile
    func deleteProfile(userId: UUID) async throws
    
    // Progress tracking
    func fetchProgress(userId: UUID) async throws -> UserProgress
    func fetchProgressByDeviceId(_ deviceId: UUID) async throws -> UserProgress
    func initializeProgress(userId: UUID) async throws -> UserProgress
    func initializeAnonymousProgress(deviceId: UUID) async throws -> UserProgress
    func updateProgress(
        userId: UUID,
        streak: Int?,
        routineCompletions: Int?,
        totalMinutes: Int?,
        lastActivity: Date?
    ) async throws -> UserProgress
    func updateAnonymousProgress(
        deviceId: UUID,
        streak: Int?,
        routineCompletions: Int?,
        totalMinutes: Int?,
        lastActivity: Date?
    ) async throws -> UserProgress
    func migrateAnonymousProgress(from deviceId: UUID, to userId: UUID) async throws -> UserProgress
    
    // Premium status
    func updatePremiumStatus(userId: UUID, isPremium: Bool, premiumUntil: Date?) async throws -> UserProfile
    
    // Utility methods
    func findProfileByAppleId(_ appleId: String) async throws -> UserProfile?
    
    // Routine completions
    func recordRoutineCompletion(
        routineId: String,
        userId: UUID?,
        deviceId: UUID?
    ) async throws -> UUID
    
    func getRecentCompletions(
        userId: UUID?,
        deviceId: UUID?,
        days: Int
    ) async throws -> [RoutineCompletion]
    
    func getCurrentStreak(userId: UUID) async throws -> Int
} 