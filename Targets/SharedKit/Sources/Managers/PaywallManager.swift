import SwiftUI
import SuperwallKit

public class PaywallManager {
    public static let shared = PaywallManager()
    
    private let defaults = UserDefaults.standard
    private let hasDeclinedFirstPaywallKey = "hasDeclinedFirstPaywall"
    private let hasDeclinedSecondPaywallKey = "hasDeclinedSecondPaywall"
    
    private init() {}
    
    public func showFirstPaywall(showSecondPaywallOnDecline: Bool = false) {
        let handler = PaywallPresentationHandler()
        handler.onDismiss { [weak self] paywallInfo, result in
            guard let self = self else { return }
            
            switch result {
            case .purchased, .restored:
                print("User purchased or restored")
                // Clear declined states since user has purchased
                self.defaults.removeObject(forKey: self.hasDeclinedFirstPaywallKey)
                self.defaults.removeObject(forKey: self.hasDeclinedSecondPaywallKey)
                
            case .declined:
                // Mark first paywall as declined
                self.defaults.set(true, forKey: self.hasDeclinedFirstPaywallKey)
                // Show second paywall only if requested
                if showSecondPaywallOnDecline {
                    self.showSecondPaywall()
                }
            }
        }
        
        handler.onPresent { paywallInfo in
            print("First paywall presented")
        }
        
        handler.onError { error in
            print("First paywall error: \(error)")
        }
        
        Superwall.shared.register(placement: "first_paywall", handler: handler) {
            // This closure is called if the paywall is skipped or after purchase
            print("First paywall flow completed")
        }
    }
    
    private func showSecondPaywall() {
        let handler = PaywallPresentationHandler()
        handler.onDismiss { [weak self] paywallInfo, result in
            guard let self = self else { return }
            
            switch result {
            case .purchased, .restored:
                print("User purchased or restored")
                // Clear declined states since user has purchased
                self.defaults.removeObject(forKey: self.hasDeclinedFirstPaywallKey)
                self.defaults.removeObject(forKey: self.hasDeclinedSecondPaywallKey)
                
            case .declined:
                // Mark second paywall as declined
                self.defaults.set(true, forKey: self.hasDeclinedSecondPaywallKey)
            }
        }
        
        handler.onPresent { paywallInfo in
            print("Second paywall presented")
        }
        
        handler.onError { error in
            print("Second paywall error: \(error)")
        }
        
        Superwall.shared.register(placement: "second_paywall", handler: handler) {
            // This closure is called if the paywall is skipped or after purchase
            print("Second paywall flow completed")
        }
    }
    
    /// Check if we should show first paywall (used when app opens)
    public func shouldShowFirstPaywall() -> Bool {
        // If user has declined both paywalls and hasn't purchased
        return defaults.bool(forKey: hasDeclinedFirstPaywallKey) && 
               defaults.bool(forKey: hasDeclinedSecondPaywallKey)
    }
} 