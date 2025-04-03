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
    public func markOnboardingCompleted(showSignIn: Bool = true, completion: @escaping () -> Void = {}) {
        defaults.set(true, forKey: hasCompletedOnboardingKey)
        
        // For onboarding, we'll use a handler to show the decline paywall
        let handler = PaywallPresentationHandler()
        handler.onDismiss { _, result in
            switch result {
            case .declined:
                // Show decline paywall (second paywall) when first one is declined
                Superwall.shared.register(placement: "paywall_closed") { [weak self] in
                    // Only show sign in after the second paywall is completed
                    if showSignIn {
                        completion()
                    }
                }
            default:
                // If they purchased from first paywall, show sign in
                if showSignIn {
                    completion()
                }
            }
        }
        
        // Present initial onboarding paywall (first paywall)
        Superwall.shared.register(placement: "onboarding_completed", handler: handler) {
            // This completion only runs if first paywall is skipped
            // In this case, we don't show sign in yet as they should see the second paywall
            Superwall.shared.register(placement: "paywall_closed") {
                if showSignIn {
                    completion()
                }
            }
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