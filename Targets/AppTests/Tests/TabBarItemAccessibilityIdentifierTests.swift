import UIKit
import XCTest
@testable import Nervespace

@MainActor
final class TabBarItemAccessibilityIdentifierTests: XCTestCase {
    func testIdentifierIsAppliedWhenTabBarAppearsAfterInitialSetup() async throws {
        let identifier = "nervespace.test.delayed-tab"
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        let rootViewController = UIViewController()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        let identifierView = TabBarItemAccessibilityIdentifier.IdentifierView(
            index: 0,
            identifier: identifier,
            retryInterval: 0.01,
            retryDuration: 1
        )
        rootViewController.view.addSubview(identifierView)

        try await Task.sleep(nanoseconds: 150_000_000)

        let tabBar = UITabBar()
        tabBar.items = [
            UITabBarItem(title: "Test", image: nil, selectedImage: nil),
        ]
        rootViewController.view.addSubview(tabBar)

        for _ in 0..<50 {
            if tabBar.items?.first?.accessibilityIdentifier == identifier {
                break
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }

        XCTAssertEqual(
            tabBar.items?.first?.accessibilityIdentifier,
            identifier
        )
    }
}
