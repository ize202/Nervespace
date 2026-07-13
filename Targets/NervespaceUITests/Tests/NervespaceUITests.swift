import XCTest

final class NervespaceUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = [
            "-ui-testing",
            "-reset-local-data",
            "-skip-onboarding",
        ]
        app.launch()
    }

    func testCompletingRoutineUpdatesProgressAndHistory() {
        tap("nervespace.routine.first")
        tap("nervespace.session.start")
        tap("nervespace.session.finish")
        tap("nervespace.completion.save")
        tapProgressTab()

        let minutesToday = element("nervespace.progress.minutes-today")
        XCTAssertTrue(minutesToday.waitForExistence(timeout: 5))
        XCTAssertEqual(minutesToday.value as? String, "1")

        tap("nervespace.progress.history-link")
        let historyRows = app.descendants(matching: .any)
            .matching(identifier: "nervespace.history.row")
        XCTAssertTrue(historyRows.firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(historyRows.count, 1)
    }

    private func tap(_ identifier: String) {
        let target = element(identifier)
        XCTAssertTrue(
            target.waitForExistence(timeout: 5),
            "Missing accessibility identifier: \(identifier)"
        )
        target.tap()
    }

    private func tapProgressTab() {
        let target = app.tabBars.buttons["Progress"].firstMatch
        XCTAssertTrue(
            target.waitForExistence(timeout: 5),
            "Missing native Progress tab"
        )
        target.tap()
    }

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }
}
