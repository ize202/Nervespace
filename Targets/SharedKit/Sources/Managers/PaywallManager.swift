import SwiftUI
import SuperwallKit

public class PaywallManager {
    public static let shared = PaywallManager()
    
    private let defaults = UserDefaults.standard
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    private init() {}
    
    /// Called when onboarding is completed
    public func markOnboardingCompleted(completion: @escaping () -> Void = {}) {
        defaults.set(true, forKey: hasCompletedOnboardingKey)
        
        // Present paywall using Superwall placement with handler
        let handler = PaywallPresentationHandler()
        Superwall.shared.register(placement: "onboarding_completed", handler: handler) {
            completion()
        }
    }
    
    /// Track app open event
    public func trackAppOpen() {
        // Only track app open for non-first launches
        if defaults.bool(forKey: hasCompletedOnboardingKey) {
            Superwall.shared.register(placement: "app_opened")
        }
    }
} 