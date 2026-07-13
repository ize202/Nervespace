import Foundation
import SwiftUI
import UIKit

struct LaunchConfiguration {
    static let current = LaunchConfiguration(
        arguments: ProcessInfo.processInfo.arguments
    )
    static let uiTestSuiteName = "com.slips.nervespace.ui-testing"

    let isUITesting: Bool
    let resetLocalData: Bool
    let skipOnboarding: Bool
    let userDefaults: UserDefaults
    private let activeUITestSuiteName: String?

    init(
        arguments: [String],
        uiTestSuiteName: String = Self.uiTestSuiteName
    ) {
        let isUITesting = arguments.contains("-ui-testing")
        self.isUITesting = isUITesting
        resetLocalData = isUITesting
            && arguments.contains("-reset-local-data")
        skipOnboarding = isUITesting
            && arguments.contains("-skip-onboarding")

        if isUITesting {
            guard let defaults = UserDefaults(
                suiteName: uiTestSuiteName
            ) else {
                fatalError("Unable to create the UI-test defaults suite")
            }
            userDefaults = defaults
            activeUITestSuiteName = uiTestSuiteName
        } else {
            userDefaults = .standard
            activeUITestSuiteName = nil
        }
    }

    func prepareUITestStore(
        fileManager: FileManager = .default,
        baseDirectory: URL? = nil
    ) throws -> URL {
        precondition(isUITesting, "UI-test storage requires -ui-testing")

        let directory = (baseDirectory ?? fileManager.temporaryDirectory)
            .appendingPathComponent("NervespaceUITests", isDirectory: true)
        if resetLocalData {
            if fileManager.fileExists(atPath: directory.path) {
                try fileManager.removeItem(at: directory)
            }
            guard let activeUITestSuiteName else {
                preconditionFailure("UI-test defaults suite is unavailable")
            }
            userDefaults.removePersistentDomain(forName: activeUITestSuiteName)
        }
        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        return directory.appendingPathComponent("routine_completions.json")
    }
}

enum AccessibilityIdentifier {
    static let onboardingCompletion = "nervespace.onboarding.complete"
    static let firstRoutine = "nervespace.routine.first"
    static let startSession = "nervespace.session.start"
    static let finishSession = "nervespace.session.finish"
    static let saveCompletion = "nervespace.completion.save"
    static let progressTab = "nervespace.tab.progress"
    static let minutesToday = "nervespace.progress.minutes-today"
    static let historyLink = "nervespace.progress.history-link"
    static let historyRow = "nervespace.history.row"
}

private struct LaunchConfigurationKey: EnvironmentKey {
    static let defaultValue = LaunchConfiguration.current
}

extension EnvironmentValues {
    var launchConfiguration: LaunchConfiguration {
        get { self[LaunchConfigurationKey.self] }
        set { self[LaunchConfigurationKey.self] = newValue }
    }
}

struct TabBarItemAccessibilityIdentifier: UIViewRepresentable {
    let index: Int
    let identifier: String

    func makeUIView(context: Context) -> IdentifierView {
        IdentifierView(index: index, identifier: identifier)
    }

    func updateUIView(_ view: IdentifierView, context: Context) {
        view.index = index
        view.identifier = identifier
        view.applyIdentifier()
    }

    final class IdentifierView: UIView {
        var index: Int
        var identifier: String
        private var attemptsRemaining = 10

        init(index: Int, identifier: String) {
            self.index = index
            self.identifier = identifier
            super.init(frame: .zero)
            isAccessibilityElement = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            attemptsRemaining = 10
            applyIdentifier()
        }

        func applyIdentifier() {
            guard
                let window,
                let tabBar = findTabBar(in: window),
                let item = tabBar.items?[safe: index]
            else {
                scheduleRetry()
                return
            }
            item.accessibilityIdentifier = identifier
        }

        private func findTabBar(in view: UIView) -> UITabBar? {
            if let tabBar = view as? UITabBar {
                return tabBar
            }
            for subview in view.subviews {
                if let match = findTabBar(in: subview) {
                    return match
                }
            }
            return nil
        }

        private func scheduleRetry() {
            guard attemptsRemaining > 0, window != nil else {
                return
            }
            attemptsRemaining -= 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                [weak self] in
                self?.applyIdentifier()
            }
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
