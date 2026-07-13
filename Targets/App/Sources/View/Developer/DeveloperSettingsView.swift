import SharedKit
import SwiftUI
import UserNotifications

struct DeveloperSettingsView: View {
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
            #if DEBUG
                List {
                    Section("LOCAL STATE") {
                        Button("Show Onboarding") {
                            showOnboarding = true
                        }

                        Button("Reset UserDefaults", role: .destructive) {
                            UserDefaults.standard.clear()
                        }
                    }

                    Section("LOCAL UI") {
                        Button("Show In-App Notification") {
                            showInAppNotification(
                                .info,
                                content: InAppNotificationContent(
                                    title: "Preview Notification",
                                    message: "This notification stays on this device."
                                ),
                                size: .normal
                            )
                        }

                        Button("Request Notification Permission") {
                            Task {
                                _ = try? await UNUserNotificationCenter.current()
                                    .requestAuthorization(
                                        options: [.alert, .sound, .badge]
                                    )
                            }
                        }

                        Button("Test App Rating Prompt") {
                            askUserFor(.appRating) {
                            } onDismiss: {
                            }
                        }
                    }
                }
                .navigationTitle("Developer Settings")
                .sheet(isPresented: $showOnboarding) {
                    OnboardingView {
                        showOnboarding = false
                    }
                }
            #endif
        }
    }
}

#Preview {
    DeveloperSettingsView()
}
