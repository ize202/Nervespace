import Foundation
import SwiftUI

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
