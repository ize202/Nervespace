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
        
        // For onboarding, we'll use a handler to show the decline paywall
        let handler = PaywallPresentationHandler()
        handler.onDismiss { _, result in
            switch result {
            case .declined:
                // Show decline paywall only during onboarding
                Superwall.shared.register(placement: "paywall_closed") {
                    completion()
                }
            default:
                completion()
            }
        }
        
        // Present initial onboarding paywall
        Superwall.shared.register(placement: "onboarding_completed", handler: handler) {
            // This completion only runs if paywall is skipped
            completion()
        }
    }
    
    /// Handle fresh app launch paywall
    public func handleAppLaunch() {
        // Only show if onboarding is completed
        guard hasCompletedOnboarding else { return }
        
        // Show new session paywall without decline flow
        let handler = PaywallPresentationHandler()
        handler.onDismiss { _, _ in
            // No additional action on decline for new sessions
        }
        
        Superwall.shared.register(placement: "new_session", handler: handler) {}
    }
} 