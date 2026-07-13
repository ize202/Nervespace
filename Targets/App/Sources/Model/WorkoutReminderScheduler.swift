import Combine
import Foundation
import UserNotifications

enum WorkoutReminderSettings {
    static let changed = Notification.Name("WorkoutReminderSettingsChanged")

    private static let enabledKey = "workout_reminder_enabled"
    private static let timeKey = "workout_reminder_time"

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: enabledKey)
    }

    static var time: Date? {
        UserDefaults.standard.object(forKey: timeKey) as? Date
    }

    static func save(isEnabled: Bool, time: Date) {
        UserDefaults.standard.set(isEnabled, forKey: enabledKey)
        UserDefaults.standard.set(time, forKey: timeKey)
        NotificationCenter.default.post(name: changed, object: nil)
    }
}

protocol ReminderNotificationScheduling: AnyObject {
    func add(
        _ request: UNNotificationRequest,
        completion: @escaping (Error?) -> Void
    )
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

private final class SystemReminderNotificationCenter:
    ReminderNotificationScheduling
{
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func add(
        _ request: UNNotificationRequest,
        completion: @escaping (Error?) -> Void
    ) {
        center.add(request, withCompletionHandler: completion)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

struct WorkoutReminderScheduler {
    static let requestIdentifier = "daily_workout_reminder"

    private let center: any ReminderNotificationScheduling

    init(
        center: any ReminderNotificationScheduling =
            SystemReminderNotificationCenter()
    ) {
        self.center = center
    }

    func update(isEnabled: Bool, time: Date) async throws {
        guard isEnabled else {
            center.removePendingNotificationRequests(
                withIdentifiers: [Self.requestIdentifier]
            )
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time for Your Daily Reset"
        content.body = "Take a moment to reset and recharge."
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.hour, .minute],
            from: time
        )
        let request = UNNotificationRequest(
            identifier: Self.requestIdentifier,
            content: content,
            trigger: UNCalendarNotificationTrigger(
                dateMatching: components,
                repeats: true
            )
        )

        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            center.add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

@MainActor
final class OnboardingReminderController: ObservableObject {
    enum Outcome: Equatable {
        case scheduled
        case denied
        case ignored
    }

    @Published private(set) var isSubmitting = false

    private let requestAuthorization: () async throws -> Bool
    private let updateReminder: (Bool, Date) async throws -> Void
    private let saveSettings: (Bool, Date) -> Void

    init() {
        let scheduler = WorkoutReminderScheduler()
        requestAuthorization = {
            try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        }
        updateReminder = { isEnabled, time in
            try await scheduler.update(isEnabled: isEnabled, time: time)
        }
        saveSettings = WorkoutReminderSettings.save
    }

    init(
        requestAuthorization: @escaping () async throws -> Bool,
        updateReminder: @escaping (Bool, Date) async throws -> Void,
        saveSettings: @escaping (Bool, Date) -> Void
    ) {
        self.requestAuthorization = requestAuthorization
        self.updateReminder = updateReminder
        self.saveSettings = saveSettings
    }

    func submit(time: Date) async throws -> Outcome {
        guard !isSubmitting else {
            return .ignored
        }

        isSubmitting = true
        defer { isSubmitting = false }

        let isAuthorized = try await requestAuthorization()
        if !isAuthorized {
            try await updateReminder(false, time)
            saveSettings(false, time)
            return .denied
        }

        try await updateReminder(true, time)
        saveSettings(true, time)
        return .scheduled
    }
}
