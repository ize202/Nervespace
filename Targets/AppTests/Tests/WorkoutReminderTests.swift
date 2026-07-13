import Foundation
import UserNotifications
import XCTest
@testable import Nervespace

final class WorkoutReminderSchedulerTests: XCTestCase {
    func testDisablingRemovesOnlyTheNervespaceReminder() async throws {
        let center = TestReminderNotificationCenter()
        let scheduler = WorkoutReminderScheduler(center: center)

        try await scheduler.update(isEnabled: false, time: Date())

        XCTAssertEqual(
            center.removedIdentifiers,
            [[WorkoutReminderScheduler.requestIdentifier]]
        )
        XCTAssertTrue(center.addedRequests.isEmpty)
    }

    func testEnablingAddsOneRepeatingCalendarRequest() async throws {
        let center = TestReminderNotificationCenter()
        let scheduler = WorkoutReminderScheduler(center: center)
        var components = DateComponents()
        components.calendar = .current
        components.hour = 7
        components.minute = 45
        let time = try XCTUnwrap(components.date)

        try await scheduler.update(isEnabled: true, time: time)

        let request = try XCTUnwrap(center.addedRequests.first)
        XCTAssertEqual(center.addedRequests.count, 1)
        XCTAssertEqual(
            request.identifier,
            WorkoutReminderScheduler.requestIdentifier
        )
        let trigger = try XCTUnwrap(
            request.trigger as? UNCalendarNotificationTrigger
        )
        XCTAssertTrue(trigger.repeats)
        XCTAssertEqual(trigger.dateComponents.hour, 7)
        XCTAssertEqual(trigger.dateComponents.minute, 45)
        XCTAssertTrue(center.removedIdentifiers.isEmpty)
    }

    func testReplacementFailurePreservesTheExistingRequest() async throws {
        let existing = UNNotificationRequest(
            identifier: WorkoutReminderScheduler.requestIdentifier,
            content: UNMutableNotificationContent(),
            trigger: nil
        )
        let center = TestReminderNotificationCenter(
            pendingRequests: [existing],
            addError: TestError.addFailed
        )
        let scheduler = WorkoutReminderScheduler(center: center)

        do {
            try await scheduler.update(isEnabled: true, time: Date())
            XCTFail("Expected replacement to fail")
        } catch TestError.addFailed {
        }

        XCTAssertEqual(
            center.pendingRequests[WorkoutReminderScheduler.requestIdentifier],
            existing
        )
        XCTAssertTrue(center.removedIdentifiers.isEmpty)
    }
}

@MainActor
final class OnboardingReminderControllerTests: XCTestCase {
    func testConcurrentSubmissionIsIgnored() async throws {
        var authorizationRequests = 0
        var scheduledReminders = 0
        var savedSettings = 0
        let controller = OnboardingReminderController(
            requestAuthorization: {
                authorizationRequests += 1
                try await Task.sleep(nanoseconds: 50_000_000)
                return true
            },
            updateReminder: { isEnabled, _ in
                XCTAssertTrue(isEnabled)
                scheduledReminders += 1
            },
            saveSettings: { isEnabled, _ in
                XCTAssertTrue(isEnabled)
                savedSettings += 1
            }
        )

        let firstSubmission = Task {
            try await controller.submit(time: Date())
        }
        while !controller.isSubmitting {
            await Task.yield()
        }

        let duplicateOutcome = try await controller.submit(time: Date())
        let firstOutcome = try await firstSubmission.value

        XCTAssertEqual(duplicateOutcome, .ignored)
        XCTAssertEqual(firstOutcome, .scheduled)
        XCTAssertEqual(authorizationRequests, 1)
        XCTAssertEqual(scheduledReminders, 1)
        XCTAssertEqual(savedSettings, 1)
    }

    func testSchedulingFailureDoesNotPersistEnabledState() async {
        var savedSettings = 0
        let controller = OnboardingReminderController(
            requestAuthorization: { true },
            updateReminder: { _, _ in throw TestError.addFailed },
            saveSettings: { _, _ in savedSettings += 1 }
        )

        do {
            _ = try await controller.submit(time: Date())
            XCTFail("Expected scheduling to fail")
        } catch TestError.addFailed {
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(savedSettings, 0)
    }
}

private enum TestError: Error {
    case addFailed
}

private final class TestReminderNotificationCenter:
    ReminderNotificationScheduling
{
    private(set) var addedRequests: [UNNotificationRequest] = []
    private(set) var removedIdentifiers: [[String]] = []
    private(set) var pendingRequests: [String: UNNotificationRequest]
    private let addError: Error?

    init(
        pendingRequests: [UNNotificationRequest] = [],
        addError: Error? = nil
    ) {
        self.pendingRequests = Dictionary(
            uniqueKeysWithValues: pendingRequests.map { ($0.identifier, $0) }
        )
        self.addError = addError
    }

    func add(
        _ request: UNNotificationRequest,
        completion: @escaping (Error?) -> Void
    ) {
        addedRequests.append(request)
        if addError == nil {
            pendingRequests[request.identifier] = request
        }
        completion(addError)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(identifiers)
        for identifier in identifiers {
            pendingRequests[identifier] = nil
        }
    }
}
