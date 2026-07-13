import SharedKit
import SwiftUI
import UserNotifications

struct WorkoutReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reminderTime: Date
    @State private var isReminderEnabled: Bool
    @State private var hasChanges = false
    @State private var isSaving = false
    @State private var showingSaveConfirmation = false
    @State private var errorMessage: String?

    private let initialReminderTime: Date
    private let initialIsEnabled: Bool

    init() {
        let savedTime = WorkoutReminderSettings.time ?? Date()
        let enabled = WorkoutReminderSettings.isEnabled
        _reminderTime = State(initialValue: savedTime)
        _isReminderEnabled = State(initialValue: enabled)
        initialReminderTime = savedTime
        initialIsEnabled = enabled
    }

    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()

            VStack(spacing: 24) {
                reminderToggle

                if isReminderEnabled {
                    timePicker
                }

                Spacer()

                Text(
                    "Nervespace can send one gentle local reminder at this time each day."
                )
                .font(.system(size: 15))
                .foregroundColor(.baseWhite.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

                if hasChanges {
                    Button(action: saveChanges) {
                        Text(isSaving ? "Saving…" : "Save Changes")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.brandPrimary)
                            .foregroundColor(.baseBlack)
                            .cornerRadius(16)
                    }
                    .disabled(isSaving)
                    .padding(.top, 16)
                }
            }
            .padding(24)

            if showingSaveConfirmation {
                Text("Settings Saved")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.baseWhite)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.baseWhite.opacity(0.1))
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .navigationTitle("Workout Reminder")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(hasChanges)
        .task {
            await reconcileAuthorization()
        }
        .alert("Reminder Unavailable", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }

    private var reminderToggle: some View {
        HStack {
            Text("Daily Reminder")
                .font(.system(size: 17))
                .foregroundColor(.baseWhite)

            Spacer()

            Toggle("", isOn: $isReminderEnabled)
                .labelsHidden()
                .onChange(of: isReminderEnabled) { _, isEnabled in
                    updateHasChanges()
                    guard isEnabled else {
                        return
                    }
                    Task {
                        await requestAuthorizationIfNeeded()
                    }
                }
                .tint(.brandPrimary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.baseWhite.opacity(0.05))
        )
    }

    private var timePicker: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reminder Time")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.baseWhite.opacity(0.7))

            DatePicker(
                "Select Time",
                selection: $reminderTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .colorScheme(.dark)
            .tint(.brandPrimary)
            .onChange(of: reminderTime) {
                updateHasChanges()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.baseWhite.opacity(0.05))
        )
    }

    private func updateHasChanges() {
        let calendar = Calendar.current
        let initialComponents = calendar.dateComponents(
            [.hour, .minute],
            from: initialReminderTime
        )
        let currentComponents = calendar.dateComponents(
            [.hour, .minute],
            from: reminderTime
        )
        hasChanges = isReminderEnabled != initialIsEnabled
            || currentComponents != initialComponents
    }

    @MainActor
    private func requestAuthorizationIfNeeded() async {
        do {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            let isAuthorized: Bool
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                isAuthorized = true
            case .notDetermined:
                isAuthorized = try await center.requestAuthorization(
                    options: [.alert, .sound, .badge]
                )
            case .denied:
                isAuthorized = false
            @unknown default:
                isAuthorized = false
            }

            guard isAuthorized else {
                isReminderEnabled = false
                updateHasChanges()
                errorMessage = "Allow notifications in Settings to enable a daily reminder."
                return
            }
        } catch {
            isReminderEnabled = false
            updateHasChanges()
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func reconcileAuthorization() async {
        let settings = await UNUserNotificationCenter.current()
            .notificationSettings()
        guard isReminderEnabled else {
            return
        }
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            break
        case .denied, .notDetermined:
            isReminderEnabled = false
            WorkoutReminderSettings.save(
                isEnabled: false,
                time: reminderTime
            )
            try? await WorkoutReminderScheduler().update(
                isEnabled: false,
                time: reminderTime
            )
            hasChanges = false
        @unknown default:
            break
        }
    }

    private func saveChanges() {
        Task {
            isSaving = true
            defer { isSaving = false }

            if isReminderEnabled {
                await requestAuthorizationIfNeeded()
                guard isReminderEnabled else {
                    return
                }
            }

            do {
                try await WorkoutReminderScheduler().update(
                    isEnabled: isReminderEnabled,
                    time: reminderTime
                )
                WorkoutReminderSettings.save(
                    isEnabled: isReminderEnabled,
                    time: reminderTime
                )
                hasChanges = false
                withAnimation {
                    showingSaveConfirmation = true
                }
                try? await Task.sleep(nanoseconds: 800_000_000)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutReminderView()
    }
}
