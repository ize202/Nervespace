//
//  Crashlytics.swift
//  Nervespace
//
//  Created by Aize Igbinakenzua on 2025-03-24.
//

import Foundation
import SharedKit
import Sentry

public class Crashlytics {
    public static let shared = Crashlytics()
    
    private init() {}
    
    public func configure() {
        print("Crashlytics.configure() called")
        // Get DSN from plist
        if let path = Bundle.main.path(forResource: "Sentry-Info", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
           let dsn = dict["SENTRY_DSN"] as? String {
            
            print("DSN found: \(dsn)")
            
            // Initialize Sentry
            SentrySDK.start { options in
                options.dsn = dsn
                options.debug = false // Set to false in production
                options.enableAutoSessionTracking = true
                options.enableSwizzling = false
                options.tracesSampleRate = 1.0
                options.profilesSampleRate = 1.0
                
                // Enable crash and error handling
                options.enableCrashHandler = true
                
                // Set environment
                #if DEBUG
                options.environment = "development"
                #else
                options.environment = "production"
                #endif
                
                print("Sentry configured with options: \(options)")
            }
        } else {
            print("Failed to configure Sentry: DSN not found in Sentry-Info.plist")
        }
    }
    
    // MARK: - Error Tracking
    
    public func captureError(_ error: Error, additionalInfo: [String: Any]? = nil) {
        SentrySDK.capture(error: error) { scope in
            if let info = additionalInfo {
                scope.setExtras(info)
            }
        }
    }
    
    public func captureMessage(_ message: String, level: SentryLevel = .info) {
        SentrySDK.capture(message: message) { scope in
            scope.setLevel(level)
        }
    }
    
    // MARK: - User Management
    
    public func setUser(id: String, email: String? = nil, username: String? = nil) {
        let user = User()
        user.userId = id
        user.email = email
        user.username = username
        
        SentrySDK.setUser(user)
    }
    
    public func clearUser() {
        SentrySDK.setUser(nil)
    }
    
//    // MARK: - Breadcrumbs
//
//    public func leaveBreadcrumb(
//        _ message: String,
//        category: String? = nil,
//        level: SentryLevel = .info,
//        data: [String: Any]? = nil
//    ) {
//        let crumb = Breadcrumb()
//        crumb.message = message
//        crumb.category = category
//        crumb.level = level
//        crumb.data = data
//
//        SentrySDK.addBreadcrumb(crumb)
//    }
    
    // MARK: - Performance Monitoring
    
    public func startTransaction(
        name: String,
        operation: String
    ) -> Span? {
        return SentrySDK.startTransaction(
            name: name,
            operation: operation
        )
    }
}
