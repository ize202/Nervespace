import SwiftUI
import SharedKit
import NotifKit

// MARK: - Common Components

struct OnboardingScreenContainer<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content
    let showNextButton: Bool
    let nextButtonTitle: String
    let onNext: () -> Void
    
    init(
        title: String,
        subtitle: String,
        showNextButton: Bool = true,
        nextButtonTitle: String = "Continue",
        onNext: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showNextButton = showNextButton
        self.nextButtonTitle = nextButtonTitle
        self.onNext = onNext
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
            
            content
                .padding(.horizontal, 24)
            
            if showNextButton {
                Button(action: onNext) {
                    Text(nextButtonTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.cta())
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            
            Spacer()
        }
    }
}

// MARK: - Welcome Screen

struct WelcomeScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.welcome.title,
            subtitle: OnboardingScreen.welcome.subtitle,
            nextButtonTitle: "Let's begin"
        ) {
            viewModel.moveToNextScreen()
        } content: {
            Image(systemName: "heart.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.brandPrimary)
                .padding(.vertical, 40)
        }
    }
}

// MARK: - Motivation Screen

struct MotivationScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    let motivations = [
        ("😣", "I feel anxious or overwhelmed a lot"),
        ("🌙", "I struggle with sleep or tension at night"),
        ("⚡️", "I want more calm and focus during the day"),
        ("🧘", "I need a consistent way to reset"),
        ("🤔", "I'm just curious — but I know I need this")
    ]
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.motivation.title,
            subtitle: OnboardingScreen.motivation.subtitle
        ) {
            viewModel.moveToNextScreen()
        } content: {
            VStack(spacing: 12) {
                ForEach(motivations, id: \.1) { emoji, text in
                    Button(action: {
                        viewModel.selections.motivation = text
                        viewModel.moveToNextScreen()
                    }) {
                        HStack(spacing: 16) {
                            Text(emoji)
                                .font(.title)
                            
                            Text(text)
                                .font(.body)
                            
                            Spacer()
                            
                            if viewModel.selections.motivation == text {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.brandPrimary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Tension Areas Screen

struct TensionAreasScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    let tensionAreas = [
        "Head / Jaw",
        "Neck & Shoulders",
        "Chest",
        "Stomach / Gut",
        "Lower Back / Hips",
        "Hands / Wrists",
        "All over",
        "Not sure"
    ]
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.tensionAreas.title,
            subtitle: OnboardingScreen.tensionAreas.subtitle
        ) {
            viewModel.moveToNextScreen()
        } content: {
            VStack(spacing: 12) {
                ForEach(tensionAreas, id: \.self) { area in
                    Button(action: {
                        if viewModel.selections.tensionAreas.contains(area) {
                            viewModel.selections.tensionAreas.remove(area)
                        } else {
                            viewModel.selections.tensionAreas.insert(area)
                        }
                    }) {
                        HStack {
                            Text(area)
                                .font(.body)
                            
                            Spacer()
                            
                            if viewModel.selections.tensionAreas.contains(area) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.brandPrimary)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Time Commitment Screen

struct TimeCommitmentScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    let timeOptions = [
        ("⏱", "2 minutes — I want something quick I can stick to"),
        ("🧘", "5 minutes — I can make a little space"),
        ("🕰", "10+ minutes — I'm ready to go deeper"),
        ("🔄", "It depends — I'll take it day by day")
    ]
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.timeCommitment.title,
            subtitle: OnboardingScreen.timeCommitment.subtitle
        ) {
            viewModel.moveToNextScreen()
        } content: {
            VStack(spacing: 12) {
                ForEach(timeOptions, id: \.1) { emoji, text in
                    Button(action: {
                        viewModel.selections.timeCommitment = text
                        viewModel.moveToNextScreen()
                    }) {
                        HStack(spacing: 16) {
                            Text(emoji)
                                .font(.title)
                            
                            Text(text)
                                .font(.body)
                            
                            Spacer()
                            
                            if viewModel.selections.timeCommitment == text {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.brandPrimary)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Reminder Screen

struct ReminderScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.reminder.title,
            subtitle: OnboardingScreen.reminder.subtitle,
            nextButtonTitle: "Set Reminder"
        ) {
            PushNotifications.showNotificationsPermissionsSheet()
            viewModel.moveToNextScreen()
        } content: {
            VStack(spacing: 24) {
                DatePicker("Select Time", selection: $viewModel.selections.reminderTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Mood Check Screen

struct MoodCheckScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.moodCheck.title,
            subtitle: OnboardingScreen.moodCheck.subtitle
        ) {
            viewModel.moveToNextScreen()
        } content: {
            VStack(spacing: 24) {
                HStack {
                    Text("Overwhelmed")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Grounded")
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $viewModel.selections.initialMood, in: 0...1)
                    .tint(.brandPrimary)
            }
            .padding(.vertical, 40)
        }
    }
}

// MARK: - Reset Plan Screen

struct ResetPlanScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var hasRequestedReview = false
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.resetPlan.title,
            subtitle: OnboardingScreen.resetPlan.subtitle,
            nextButtonTitle: "Start Day 1 Now"
        ) {
            if !hasRequestedReview {
                askUserFor(.appRating) {
                    // On successful rating or dismissal, set the flag and continue
                    hasRequestedReview = true
                }
            } else {
                viewModel.moveToNextScreen()
            }
        } content: {
            VStack(spacing: 16) {
                PlanDayView(day: 1, title: "Grounding Breath", isLocked: false)
                PlanDayView(day: 2, title: "Release Tension", isLocked: true)
                PlanDayView(day: 3, title: "Full Reset", isLocked: true)
            }
            .padding(.vertical, 20)
        }
    }
}

struct PlanDayView: View {
    let day: Int
    let title: String
    let isLocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text("Day \(day)")
                .font(.headline)
                .foregroundColor(.brandPrimary)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: isLocked ? "lock.fill" : "checkmark.circle.fill")
                .foregroundColor(isLocked ? .secondary : .brandPrimary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Breathing Exercise Screen

struct BreathingExerciseScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var scale: CGFloat = 1.0
    @State private var isInhaling = false
    @State private var cyclesCompleted = 0
    let totalCycles = 5
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.breathingExercise.title,
            subtitle: OnboardingScreen.breathingExercise.subtitle,
            showNextButton: false
        ) {
            viewModel.moveToNextScreen()
        } content: {
            VStack(spacing: 40) {
                ZStack {
                    Circle()
                        .stroke(Color.brandPrimary.opacity(0.2), lineWidth: 2)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .fill(Color.brandPrimary.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .scaleEffect(scale)
                        .animation(.easeInOut(duration: 4), value: scale)
                    
                    Text(isInhaling ? "Hold to Inhale" : "Release to Exhale")
                        .font(.headline)
                        .foregroundColor(.brandPrimary)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            isInhaling = true
                            scale = 1.5
                        }
                        .onEnded { _ in
                            isInhaling = false
                            scale = 1.0
                            cyclesCompleted += 1
                            
                            if cyclesCompleted >= totalCycles {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    viewModel.moveToNextScreen()
                                }
                            }
                        }
                )
                
                Text("\(cyclesCompleted)/\(totalCycles) breaths completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 40)
        }
    }
}

// MARK: - Progress Screen

struct ProgressScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.progress.title,
            subtitle: OnboardingScreen.progress.subtitle,
            nextButtonTitle: "Unlock Full Plan"
        ) {
            viewModel.moveToNextScreen()
        } content: {
            VStack(spacing: 24) {
                ProgressBar(progress: 0.33)
                    .frame(height: 8)
                
                VStack(spacing: 16) {
                    PlanDayView(day: 1, title: "Grounding Breath", isLocked: false)
                    PlanDayView(day: 2, title: "Release Tension", isLocked: true)
                    PlanDayView(day: 3, title: "Full Reset", isLocked: true)
                }
            }
            .padding(.vertical, 20)
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.brandPrimary.opacity(0.2))
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color.brandPrimary)
                    .frame(width: geometry.size.width * progress)
                    .cornerRadius(4)
            }
        }
    }
}

#Preview {
    WelcomeScreen(viewModel: OnboardingViewModel())
} 