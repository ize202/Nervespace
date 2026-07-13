import Foundation
import XCTest
@testable import Nervespace

final class LaunchConfigurationTests: XCTestCase {
    func testTestOnlyArgumentsAreIgnoredWithoutUITestingFlag() {
        let configuration = LaunchConfiguration(arguments: [
            "Nervespace",
            "-reset-local-data",
            "-skip-onboarding",
        ])

        XCTAssertFalse(configuration.isUITesting)
        XCTAssertFalse(configuration.resetLocalData)
        XCTAssertFalse(configuration.skipOnboarding)
        XCTAssertTrue(configuration.userDefaults === UserDefaults.standard)
    }

    func testUITestingArgumentsEnableIsolatedLaunchBehavior() {
        let configuration = LaunchConfiguration(arguments: [
            "Nervespace",
            "-ui-testing",
            "-reset-local-data",
            "-skip-onboarding",
        ])

        XCTAssertTrue(configuration.isUITesting)
        XCTAssertTrue(configuration.resetLocalData)
        XCTAssertTrue(configuration.skipOnboarding)
    }

    func testResetClearsOnlyTheUITestSuiteAndDirectory() throws {
        let uiTestSuiteName =
            "com.slips.nervespace.ui-testing.\(UUID().uuidString)"
        let configuration = LaunchConfiguration(
            arguments: [
                "Nervespace",
                "-ui-testing",
                "-reset-local-data",
            ],
            uiTestSuiteName: uiTestSuiteName
        )
        let controlSuiteName = "com.slips.nervespace.control.\(UUID().uuidString)"
        let controlDefaults = try XCTUnwrap(
            UserDefaults(suiteName: controlSuiteName)
        )
        let baseDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer {
            configuration.userDefaults.removePersistentDomain(
                forName: uiTestSuiteName
            )
            controlDefaults.removePersistentDomain(forName: controlSuiteName)
            try? FileManager.default.removeItem(at: baseDirectory)
        }

        configuration.userDefaults.set(true, forKey: "ui-test-value")
        controlDefaults.set(true, forKey: "control-value")
        let staleDirectory = baseDirectory.appendingPathComponent(
            "NervespaceUITests",
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: staleDirectory,
            withIntermediateDirectories: true
        )
        let staleFile = staleDirectory.appendingPathComponent("stale.json")
        try Data("stale".utf8).write(to: staleFile)

        let storeURL = try configuration.prepareUITestStore(
            baseDirectory: baseDirectory
        )

        XCTAssertNil(
            configuration.userDefaults.object(forKey: "ui-test-value")
        )
        XCTAssertTrue(controlDefaults.bool(forKey: "control-value"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: staleFile.path))
        XCTAssertEqual(
            storeURL.lastPathComponent,
            "routine_completions.json"
        )
        XCTAssertEqual(
            storeURL.deletingLastPathComponent().lastPathComponent,
            "NervespaceUITests"
        )
    }
}
