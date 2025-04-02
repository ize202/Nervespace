import SwiftUI
import SuperwallKit

public class PaywallManager {
    public static let shared = PaywallManager()
    
    private let defaults = UserDefaults.standard
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    private init() {}
    
    /// Called when onboarding is completed to show hard paywall
    public func markOnboardingCompleted(completion: @escaping () -> Void = {}) {
        // Present hard paywall using Superwall
        Superwall.shared.register(placement: "onboarding_completed") {
            completion()
        }
    }
} 