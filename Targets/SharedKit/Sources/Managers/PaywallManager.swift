import SwiftUI
import SuperwallKit

public class PaywallManager {
    public static let shared = PaywallManager()
    
    private let defaults = UserDefaults.standard
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    private init() {}
    
    public var hasCompletedOnboarding: Bool {
        defaults.bool(forKey: hasCompletedOnboardingKey)
    }
    
    /// Called when onboarding is completed to show hard paywall
    public func markOnboardingCompleted(completion: @escaping () -> Void = {}) {
        defaults.set(true, forKey: hasCompletedOnboardingKey)
        // Present hard paywall using Superwall
        Superwall.shared.register(placement: "onboarding_completed") {
            completion()
        }
    }
    
    /// Handle fresh app launch paywall
    public func handleAppLaunch() {
        // Only show if onboarding is completed
        guard hasCompletedOnboarding else { return }
        
        // Show paywall on fresh app launch for non-subscribers
        Superwall.shared.register(placement: "new_session") {}
    }
} 