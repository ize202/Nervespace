import Foundation

public protocol UserService {
    // Profile management
    func fetchProfile(userId: UUID) async throws -> Model.UserProfile
    func createProfile(appleId: String, email: String?, name: String?) async throws -> Model.UserProfile
    func updateProfile(userId: UUID, name: String?, avatarURL: URL?) async throws -> Model.UserProfile
    func deleteProfile(userId: UUID) async throws
    
    // Progress tracking
    func fetchProgress(userId: UUID) async throws -> Model.UserProgress
    func fetchProgressByDeviceId(_ deviceId: UUID) async throws -> Model.UserProgress
    
    // Routine completions
    func recordRoutineCompletion(
        routineId: String,
        durationMinutes: Int,
        userId: UUID?,
        deviceId: UUID?
    ) async throws -> UUID
    
    func getRecentCompletions(
        userId: UUID?,
        deviceId: UUID?,
        days: Int
    ) async throws -> [Model.RoutineCompletion]
    
    // Account migration
    func migrateAnonymousProgress(
        from deviceId: UUID,
        to userId: UUID
    ) async throws
    
    // Premium status
    func updatePremiumStatus(
        userId: UUID,
        isPremium: Bool,
        premiumUntil: Date?
    ) async throws -> Model.UserProfile
    
    // Utility methods
    func findProfileByAppleId(_ appleId: String) async throws -> Model.UserProfile?
}

public struct UserProgress {
    public let id: UUID
    public let userId: UUID?
    public let deviceId: UUID?
    public let streak: Int
    public let dailyMinutes: Int
    public let totalMinutes: Int
    public let lastActivity: Date?
    public let createdAt: Date
    
    public init(
        id: UUID,
        userId: UUID?,
        deviceId: UUID?,
        streak: Int,
        dailyMinutes: Int,
        totalMinutes: Int,
        lastActivity: Date?,
        createdAt: Date
    ) {
        self.id = id
        self.userId = userId
        self.deviceId = deviceId
        self.streak = streak
        self.dailyMinutes = dailyMinutes
        self.totalMinutes = totalMinutes
        self.lastActivity = lastActivity
        self.createdAt = createdAt
    }
}

public struct RoutineCompletion {
    public let id: UUID
    public let userId: UUID?
    public let deviceId: UUID?
    public let routineId: String
    public let completedAt: Date
    public let durationMinutes: Int
    
    public init(
        id: UUID,
        userId: UUID?,
        deviceId: UUID?,
        routineId: String,
        completedAt: Date,
        durationMinutes: Int
    ) {
        self.id = id
        self.userId = userId
        self.deviceId = deviceId
        self.routineId = routineId
        self.completedAt = completedAt
        self.durationMinutes = durationMinutes
    }
} 