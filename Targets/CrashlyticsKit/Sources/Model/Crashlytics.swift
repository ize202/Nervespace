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
        print("[CRASHLYTICS] Configure called")
        // Get DSN from plist
        let bundle = Bundle(for: type(of: self))
        print("[CRASHLYTICS] Bundle identifier: \(bundle.bundleIdentifier ?? "unknown")")
        
        if let path = bundle.path(forResource: "Sentry-info", ofType: "plist") {
            print("[CRASHLYTICS] Found Sentry-info.plist at path: \(path)")
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                print("[CRASHLYTICS] Loaded plist contents: \(dict)")
                if let dsn = dict["SENTRY_DSN"] as? String {
                    print("[CRASHLYTICS] Found DSN: \(dsn)")
                    
                    // Initialize Sentry
                    SentrySDK.start { options in
                        options.dsn = dsn
                        options.debug = true // Enable debug mode temporarily
                        options.enableAutoSessionTracking = true
                        options.enableSwizzling = true
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
                        
                        print("[CRASHLYTICS] Sentry configured with options: \(options)")
                    }
                    print("[CRASHLYTICS] Sentry SDK started")
                } else {
                    print("[CRASHLYTICS] ERROR: DSN not found in plist dictionary")
                }
            } else {
                print("[CRASHLYTICS] ERROR: Could not load plist as dictionary")
            }
        } else {
            print("[CRASHLYTICS] ERROR: Sentry-info.plist not found in bundle")
            // Try main bundle as fallback
            if let mainPath = Bundle.main.path(forResource: "Sentry-info", ofType: "plist") {
                print("[CRASHLYTICS] Found Sentry-info.plist in main bundle: \(mainPath)")
            } else {
                print("[CRASHLYTICS] ERROR: Sentry-info.plist not found in main bundle either")
            }
        }
    }
    
    // MARK: - Error Tracking
    
    public func captureError(_ error: Error, additionalInfo: [String: Any]? = nil) {
        print("[CRASHLYTICS] Capturing error: \(error)")
        SentrySDK.capture(error: error) { scope in
            if let info = additionalInfo {
                scope.setExtras(info)
            }
            print("[CRASHLYTICS] Error captured with scope: \(scope)")
        }
    }
    
    public func captureMessage(_ message: String, level: SentryLevel = .info) {
        print("[CRASHLYTICS] Capturing message: \(message) with level: \(level)")
        SentrySDK.capture(message: message) { scope in
            scope.setLevel(level)
            print("[CRASHLYTICS] Message captured with scope: \(scope)")
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
