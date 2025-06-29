//
//  SupabaseBackend.swift
//  SupabaseKit (Generated by SwiftyLaunch 1.5.0)
//  https://docs.swiftylaun.ch/module/authkit
//  https://docs.swiftylaun.ch/module/databasekit
//

import AuthenticationServices
import Foundation
import SharedKit
import Supabase
import SwiftUI
import os

/// Enum representing authentication states.
public enum AuthState {
	case signedOut
	case signedIn
}

@MainActor
public class DB: ObservableObject {
	/// Variable reference to access Supabase.
	internal let _db: SupabaseClient
	
	/// User service for handling user-related operations
	public private(set) lazy var userService: UserService = {
		SupabaseUserService(client: _db)
	}()
	
	/// SupabaseAuth user state, nil if not logged in
	@Published public var currentUser: User? = nil
	
	/// SupabaseAuth State (use this to check auth state, updates with currentUser)
	@Published public var authState: AuthState = .signedOut
	
	/// Progress tracking properties
	@Published public private(set) var currentStreak: Int = 0
	@Published public private(set) var dailyMinutes: Int = 0
	@Published public private(set) var totalMinutes: Int = 0
	@Published public private(set) var lastActivity: Date?
	
	/// Routine completion history
	@Published public private(set) var recentCompletions: [Model.RoutineCompletion] = []
	
	/// For Sign in With Apple (see SignInWithApple.siwft)
	internal var currentNonce: String?
	
	/// Initialization state
	@Published private(set) var isInitialized = false
	
	/// For Supabase to keep track of the Auth State (see AuthGeneral.swift)
	internal var authStateHandler: AuthStateChangeListenerRegistration?
	
	/// For Sign in With Apple (specifically, for account deletion. Is set when the user signs in with Apple)
	internal var appleIDCredential: ASAuthorizationAppleIDCredential?
	
	private let defaults = UserDefaults.standard
	private let deviceIdKey = "device_uuid"
	
	/// Device UUID for anonymous users
	private var deviceId: UUID {
		if let storedId = defaults.string(forKey: deviceIdKey),
		   let uuid = UUID(uuidString: storedId) {
			return uuid
		}
		let newId = UUID()
		defaults.set(newId.uuidString, forKey: deviceIdKey)
		return newId
	}
	
	///- Parameter onAuthStateChange: Additional closure to pass to the AuthState Listener.
	/// We use this to set all the different providers to use the same, supabase-issued user ID to identify the user.
	public init(
		onAuthStateChange: @escaping (AuthChangeEvent, Session?) -> Void = { _, _ in }
	) {
		#if DEBUG
		let urlKey = "SUPABASE_DEV_URL"
		let apiKeyKey = "SUPABASE_DEV_KEY"
		print("[DB] Using development database")
		#else
		let urlKey = "SUPABASE_URL"
		let apiKeyKey = "SUPABASE_KEY"
		print("[DB] Using production database")
		#endif
		
		let supabaseURLString = try? getPlistEntry(urlKey, in: "Supabase-Info")
		let apiKey = try? getPlistEntry(apiKeyKey, in: "Supabase-Info")
		
		guard let apiKey, let supabaseURLString, let supabaseURL = URL(string: supabaseURLString) else {
			fatalError("ERROR: Couldn't get SupabaseURL and API Keys in Supabase-Info.plist!")
		}
		
		_db = SupabaseClient(
			supabaseURL: supabaseURL,
			supabaseKey: apiKey
		)
		
		Task {
			print("[DB] Registering auth state listener...")
			await registerAuthStateListener(additionalHandler: onAuthStateChange)
			
			// Check current session
			if let session = try? await _db.auth.session {
				print("[DB] Found existing session, updating auth state...")
				await MainActor.run {
					self.currentUser = session.user
					self.authState = .signedIn
				}
				print("[DB] Initial progress load...")
				do {
					try await loadProgress()
				} catch {
					// If loading progress fails for a new user, try to initialize them
					if let err = error as? NSError, err.localizedDescription.contains("multiple (or no) rows") {
						print("[DB] No progress found, attempting to initialize new user...")
						try await initializeNewUser()
					} else {
						// Handle or log other errors here if needed
						print("[DB] Unexpected error loading progress: \(error)")
						throw error
					}
				}
			} else {
				print("[DB] No existing session found")
				await MainActor.run {
					self.currentUser = nil
					self.authState = .signedOut
				}
			}
		}
	}
	
	// MARK: - Progress Tracking
	
	public func loadProgress() async throws {
		print("[DB] Attempting to load progress...")
		guard authState == .signedIn, let userId = currentUser?.id else {
			print("[DB] Cannot load progress - User not authenticated. AuthState: \(authState), User: \(String(describing: currentUser))")
			throw NSError(domain: "SupabaseKit", code: 401, userInfo: [NSLocalizedDescriptionKey: "User must be authenticated"])
		}
		
		print("[DB] Loading progress for user: \(userId)")
		
		do {
			let progress = try await userService.fetchProgress(userId: userId)
			print("[DB] Successfully fetched progress from server")
			
			await MainActor.run {
				currentStreak = progress.streak
				dailyMinutes = progress.dailyMinutes
				totalMinutes = progress.totalMinutes
				lastActivity = progress.lastActivity
				print("[DB] Updated local state with progress: streak=\(progress.streak), dailyMinutes=\(progress.dailyMinutes), totalMinutes=\(progress.totalMinutes)")
			}
			
			// Try to load completions, but don't reset progress if it fails
			print("[DB] Loading recent completions...")
			do {
                self.recentCompletions = try await loadRecentCompletions()
			} catch {
				print("[DB] Error loading completions: \(error). Keeping existing progress data.")
			}
		} catch {
			print("[DB] Error loading progress: \(error)")
			throw error // Let the caller handle initialization if needed
		}
	}
	
	public func recordCompletion(
		routine: SharedKit.Routine,
		durationMinutes: Int
	) async throws -> UUID {
		guard authState == .signedIn, let userId = currentUser?.id else {
			throw NSError(domain: "SupabaseKit", code: 401, userInfo: [NSLocalizedDescriptionKey: "User must be authenticated"])
		}
		
		return try await userService.recordRoutineCompletion(
			routineId: routine.id,
			durationMinutes: durationMinutes,
			userId: userId
		)
	}
	
	public func getRecentCompletions() async throws -> [Model.RoutineCompletion] {
		guard authState == .signedIn, let userId = currentUser?.id else {
			throw NSError(domain: "SupabaseKit", code: 401, userInfo: [NSLocalizedDescriptionKey: "User must be authenticated"])
		}
		
		return try await userService.getRecentCompletions(
			userId: userId,
			days: 30
		)
	}
	
	public func loadRecentCompletions() async throws -> [Model.RoutineCompletion] {
		os_log(.debug, "Loading recent completions...")
		
		guard let userId = currentUser?.id else {
			os_log(.error, "Cannot load recent completions - no user ID available")
			throw SupabaseError.notAuthenticated
		}
		
		let response = try await _db.database
			.rpc("get_recent_completions", params: ["p_days": "30"])
			.execute()
		
		guard let data = response.data as? Data else {
			os_log(.error, "No data returned from get_recent_completions")
			throw SupabaseError.noData
		}
		
		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .iso8601
			let completions = try decoder.decode([Model.RoutineCompletion].self, from: data)
			os_log(.debug, "Successfully loaded %d recent completions", completions.count)
			return completions
		} catch {
			os_log(.error, "Failed to decode recent completions: %{public}@", error.localizedDescription)
			throw SupabaseError.decodingError(error)
		}
	}
	
	internal func initializeNewUser() async {
		print("[DB] Initializing new user...")
		do {
			try await _db.database
				.rpc("setup_new_user")
				.execute()
			print("[DB] Successfully initialized new user")
			
			// Reload progress after initialization
			try await loadProgress()
		} catch {
			print("[DB] Error initializing new user:", error)
		}
	}
}

