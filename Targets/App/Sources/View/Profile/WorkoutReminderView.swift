import SwiftUI
import SharedKit
import NotifKit

struct WorkoutReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var reminderTime: Date
    @State private var isReminderEnabled: Bool
    @State private var hasRequestedPermission = false
    @State private var hasChanges = false
    @State private var showingSaveConfirmation = false
    
    // Store initial values to track changes
    private let initialReminderTime: Date
    private let initialIsEnabled: Bool
    
    init() {
        let savedTime = UserDefaults.standard.object(forKey: "workout_reminder_time") as? Date ?? Date()
        let enabled = UserDefaults.standard.bool(forKey: "workout_reminder_enabled")
        _reminderTime = State(initialValue: savedTime)
        _isReminderEnabled = State(initialValue: enabled)
        initialReminderTime = savedTime
        initialIsEnabled = enabled
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                hasRequestedPermission = true
                isReminderEnabled = granted
                if granted {
                    hasChanges = true
                }
            }
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                hasRequestedPermission = settings.authorizationStatus != .notDetermined
                isReminderEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func saveChanges() {
        UserDefaults.standard.set(isReminderEnabled, forKey: "workout_reminder_enabled")
        UserDefaults.standard.set(reminderTime, forKey: "workout_reminder_time")
        hasChanges = false
        showingSaveConfirmation = true
        
        // Hide confirmation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showingSaveConfirmation = false
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.baseBlack.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Enable/Disable Toggle
                    HStack {
                        Text("Daily Reminder")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.baseWhite)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isReminderEnabled)
                            .onChange(of: isReminderEnabled) { newValue in
                                if newValue && !hasRequestedPermission {
                                    requestNotificationPermission()
                                }
                                hasChanges = newValue != initialIsEnabled
                            }
                            .tint(.brandPrimary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.baseWhite.opacity(0.05))
                    )
                    
                    if isReminderEnabled {
                        // Time Picker
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Reminder Time")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.baseWhite.opacity(0.7))
                            
                            DatePicker("Select Time",
                                     selection: $reminderTime,
                                     displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .colorScheme(.dark)
                                .accentColor(.brandPrimary)
                                .onChange(of: reminderTime) { newValue in
                                    // Compare hours and minutes only
                                    let calendar = Calendar.current
                                    let initialComponents = calendar.dateComponents([.hour, .minute], from: initialReminderTime)
                                    let newComponents = calendar.dateComponents([.hour, .minute], from: newValue)
                                    hasChanges = initialComponents != newComponents
                                }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.baseWhite.opacity(0.05))
                        )
                    }
                    
                    Spacer()
                    
                    // Helper Text
                    Text("We'll send you a gentle reminder to take a moment for yourself at this time each day.")
                        .font(.system(size: 15))
                        .foregroundColor(.baseWhite.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Save Button
                    if hasChanges {
                        Button(action: saveChanges) {
                            Text("Save Changes")
                                .font(.system(size: 17, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.brandPrimary)
                                .foregroundColor(.baseBlack)
                                .cornerRadius(16)
                        }
                        .padding(.top, 16)
                    }
                }
                .padding(24)
                
                // Save Confirmation Overlay
                if showingSaveConfirmation {
                    VStack {
                        Text("Settings Saved")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.baseWhite)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.baseWhite.opacity(0.1))
                            )
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(), value: showingSaveConfirmation)
                }
            }
            .navigationTitle("Workout Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if hasChanges {
                            // Optionally, you could add an alert here to confirm discarding changes
                            saveChanges() // Auto-save on dismiss
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.baseWhite)
                    }
                }
            }
        }
        .onAppear {
            checkNotificationStatus()
        }
    }
}

#Preview {
    WorkoutReminderView()
} 