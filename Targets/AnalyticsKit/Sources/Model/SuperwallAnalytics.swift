import Foundation
import SuperwallKit
import Mixpanel

public class SuperwallAnalytics: SuperwallDelegate {
    public static let shared = SuperwallAnalytics()
    
    private init() {}
    
    public func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .transactionComplete(let transaction, let product, let paywallInfo):
            Analytics.capture(
                .success,
                id: "superwall_transaction_complete",
                longDescription: "User completed a transaction",
                source: .general,
                relevancy: .high,
                properties: [
                    "transaction_id": transaction?.storeTransactionId ?? "",
                    "original_transaction_id": transaction?.originalTransactionIdentifier ?? "",
                    "product_id": product.productIdentifier,
                    "paywall_id": paywallInfo.identifier
                ]
            )
            
        case .transactionRestore(let restoreType, let paywallInfo):
            Analytics.capture(
                .success,
                id: "superwall_transaction_restore",
                longDescription: "User restored purchases",
                source: .general,
                relevancy: .high,
                properties: [
                    "restore_type": restoreType.description,
                    "paywall_id": paywallInfo.identifier
                ]
            )
            
        case .paywallOpen(let paywallInfo):
            Analytics.capture(
                .info,
                id: "superwall_paywall_open",
                longDescription: "Paywall was opened",
                source: .general,
                properties: [
                    "paywall_id": paywallInfo.identifier
                ]
            )
            
        case .paywallClose(let paywallInfo):
            Analytics.capture(
                .info,
                id: "superwall_paywall_close",
                longDescription: "Paywall was closed",
                source: .general,
                properties: [
                    "paywall_id": paywallInfo.identifier
                ]
            )
            
        case .paywallDecline(let paywallInfo):
            Analytics.capture(
                .info,
                id: "superwall_paywall_decline",
                longDescription: "User declined paywall",
                source: .general,
                properties: [
                    "paywall_id": paywallInfo.identifier
                ]
            )
            
        case let .customPlacement(name, params, paywallInfo):
            Analytics.capture(
                .info,
                id: "superwall_custom_placement",
                longDescription: "Custom placement triggered",
                source: .general,
                properties: [
                    "placement_name": name,
                    "placement_params": params ?? [:],
                    "paywall_id": paywallInfo?.identifier ?? ""
                ]
            )
            
        default:
            break
        }
    }
    
    public func subscriptionStatusDidChange(from oldValue: SubscriptionStatus, to newValue: SubscriptionStatus) {
        Analytics.capture(
            .info,
            id: "superwall_subscription_status_change",
            longDescription: "Subscription status changed",
            source: .general,
            properties: [
                "old_status": String(describing: oldValue),
                "new_status": String(describing: newValue)
            ]
        )
    }
} 