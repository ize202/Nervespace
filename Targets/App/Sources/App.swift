import LocalDataKit
import SharedKit
import SwiftUI
import UIKit

@main
struct MainApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var activityStore: LocalActivityStore

    init() {
        _activityStore = StateObject(wrappedValue: Self.makeActivityStore())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(\.colorScheme, .dark)
                .modifier(ShowRequestSheetWhenNeededModifier())
                .modifier(ShowOnboardingViewOnFirstLaunchEverModifier())
                .environmentObject(activityStore)
        }
    }

    private static func makeActivityStore() -> LocalActivityStore {
        do {
            let fileManager = FileManager.default
            let applicationSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("Nervespace", isDirectory: true)
            .appendingPathComponent("routine_completions.json")
            let documentsURL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("routine_completions.json")

            try LegacyRoutineHistoryMigrator(
                sourceURL: documentsURL,
                destinationURL: applicationSupportURL,
                fileManager: fileManager
            ).migrate()

            return try LocalActivityStore(
                persistence: JSONRoutineHistoryPersistence(
                    fileURL: applicationSupportURL,
                    fileManager: fileManager
                ),
                defaults: .standard,
                calendar: .current,
                now: { Date() }
            )
        } catch {
            fatalError(
                "Unable to load local activity history: \(error.localizedDescription)"
            )
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(
            name: nil,
            sessionRole: connectingSceneSession.role
        )
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
    }
}

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    private var overlayWindow: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        setupOverlayWindow(in: windowScene)
        UIView.appearance(
            whenContainedInInstancesOf: [UIAlertController.self]
        ).tintColor = UIColor(named: "AccentColor")
    }

    private func setupOverlayWindow(in scene: UIWindowScene) {
        let rootView = EmptyView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modifier(ShowInAppNotificationsWhenCalledModifier())
        let viewController = UIHostingController(rootView: rootView)
        viewController.view.backgroundColor = .clear

        let window = PassThroughWindow(windowScene: scene)
        window.rootViewController = viewController
        window.isHidden = false
        overlayWindow = window
    }
}

private final class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else {
            return nil
        }
        return rootViewController?.view == hitView ? nil : hitView
    }
}
