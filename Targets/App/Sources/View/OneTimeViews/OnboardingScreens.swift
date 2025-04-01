import SwiftUI
import SharedKit
import NotifKit
import UserNotifications
import StoreKit

// MARK: - Common Components

struct OnboardingScreenContainer<Content: View>: View {
    let title: String
    let subtitle: String
    let content: Content
    let isNextButtonEnabled: Bool
    let nextButtonTitle: String
    let onNext: () -> Void
    let onBack: () -> Void
    let progress: CGFloat
    
    init(
        title: String,
        subtitle: String,
        progress: CGFloat,
        isNextButtonEnabled: Bool = true,
        nextButtonTitle: String = "Continue",
        onNext: @escaping () -> Void = {},
        onBack: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isNextButtonEnabled = isNextButtonEnabled
        self.nextButtonTitle = nextButtonTitle
        self.onNext = onNext
        self.onBack = onBack
        self.progress = progress
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.baseBlack.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Top Navigation Bar
                    HStack(spacing: 16) {
                        Button(action: onBack) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.baseWhite)
                        }
                        
                        GeometryReader { barGeometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.baseWhite.opacity(0.1))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(Color.baseWhite)
                                    .frame(width: barGeometry.size.width * progress, height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(height: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 12) {
                                Text(title)
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.baseWhite)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                if !subtitle.isEmpty {
                                    Text(subtitle)
                                        .font(.system(size: 17, weight: .regular))
                                        .foregroundColor(.baseWhite.opacity(0.7))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(.top, 32)
                            
                            content
                                .padding(.top, 24)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Button(action: onNext) {
                        Text(nextButtonTitle)
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.brandPrimary.opacity(isNextButtonEnabled ? 1 : 0.5))
                            .foregroundColor(.baseBlack)
                            .cornerRadius(16)
                    }
                    .disabled(!isNextButtonEnabled)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        Color.baseBlack
                            .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: -8)
                    )
                }
            }
        }
    }
}

// Helper extension for glassmorphism effect
extension View {
    func glassmorphism() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.baseWhite.opacity(0.05))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.baseBlack)
                            .opacity(0.5)
                            .blur(radius: 8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.baseWhite.opacity(0.1), lineWidth: 1)
                    )
            )
            .compositingGroup()
    }
}

// MARK: - Welcome Screen

struct WelcomeScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    let exercises = [
        ("figure.mind.and.body", "Somatic"),
        ("lungs", "Breathwork"),
        ("figure.yoga", "Yoga"),
        ("sparkles", "Recovery")
    ]
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.welcome.title,
            subtitle: OnboardingScreen.welcome.subtitle,
            progress: 0.1,
            isNextButtonEnabled: true,
            nextButtonTitle: "Let's begin",
            onNext: {
                viewModel.moveToNextScreen()
            },
            onBack: {
                viewModel.moveToPreviousScreen()
            }
        ) {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 24) {
                ForEach(exercises, id: \.0) { systemName, title in
                    VStack(spacing: 16) {
                        Image(systemName: systemName)
                            .font(.system(size: 44, weight: .light))
                            .foregroundColor(.brandPrimary)
                            .frame(width: 96, height: 96)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.baseBlack)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color.brandPrimary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        
                        Text(title)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.baseWhite.opacity(0.7))
                    }
                }
            }
            .padding(.vertical, 40)
        }
    }
}

// MARK: - Motivation Screen

struct MotivationScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    let motivations = [
        "I feel anxious or overwhelmed a lot",
        "I struggle with sleep or tension at night",
        "I want more calm and focus during the day",
        "I need a consistent way to reset",
        "I'm just curious — but I know I need this"
    ]
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.motivation.title,
            subtitle: OnboardingScreen.motivation.subtitle,
            progress: 0.2,
            isNextButtonEnabled: !viewModel.selections.motivation.isEmpty,
            onNext: {
                viewModel.moveToNextScreen()
            },
            onBack: {
                viewModel.moveToPreviousScreen()
            }
        ) {
            VStack(spacing: 12) {
                ForEach(motivations, id: \.self) { text in
                    Button(action: {
                        viewModel.selections.motivation = text
                    }) {
                        HStack(alignment: .center, spacing: 16) {                            
                            Text(text)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.baseWhite)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if viewModel.selections.motivation == text {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.brandPrimary)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .glassmorphism()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.brandPrimary.opacity(viewModel.selections.motivation == text ? 0.1 : 0))
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
            subtitle: OnboardingScreen.tensionAreas.subtitle,
            progress: 0.3,
            isNextButtonEnabled: !viewModel.selections.tensionAreas.isEmpty,
            nextButtonTitle: "Continue",
            onNext: {
                viewModel.moveToNextScreen()
            },
            onBack: {
                viewModel.moveToPreviousScreen()
            }
        ) {
            VStack(spacing: 12) {
                ForEach(tensionAreas, id: \.self) { area in
                    Button(action: {
                        if viewModel.selections.tensionAreas.contains(area) {
                            viewModel.selections.tensionAreas.remove(area)
                        } else {
                            viewModel.selections.tensionAreas.insert(area)
                        }
                    }) {
                        HStack(alignment: .center, spacing: 16) {
                            Text(area)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.baseWhite)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if viewModel.selections.tensionAreas.contains(area) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.brandPrimary)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .glassmorphism()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.brandPrimary.opacity(viewModel.selections.tensionAreas.contains(area) ? 0.1 : 0))
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
        "2 minutes — I want something quick I can stick to",
        "5 minutes — I can make a little space",
        "10+ minutes — I'm ready to go deeper",
        "It depends — I'll take it day by day"
    ]
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.timeCommitment.title,
            subtitle: OnboardingScreen.timeCommitment.subtitle,
            progress: 0.4,
            isNextButtonEnabled: !viewModel.selections.timeCommitment.isEmpty,
            onNext: {
                viewModel.moveToNextScreen()
            },
            onBack: {
                viewModel.moveToPreviousScreen()
            }
        ) {
            VStack(spacing: 12) {
                ForEach(timeOptions, id: \.self) { text in
                    Button(action: {
                        viewModel.selections.timeCommitment = text
                    }) {
                        HStack(alignment: .center, spacing: 16) {
                            Text(text)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.baseWhite)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if viewModel.selections.timeCommitment == text {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.brandPrimary)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .glassmorphism()
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.brandPrimary.opacity(viewModel.selections.timeCommitment == text ? 0.1 : 0))
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
    @State private var hasRequestedPermission = false
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                hasRequestedPermission = true
                if granted {
                    viewModel.moveToNextScreen()
                }
            }
        }
    }
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.reminder.title,
            subtitle: OnboardingScreen.reminder.subtitle,
            progress: 0.5,
            isNextButtonEnabled: true,
            nextButtonTitle: hasRequestedPermission ? "Skip" : "Set Reminder",
            onNext: {
                if !hasRequestedPermission {
                    requestNotificationPermission()
                } else {
                    viewModel.moveToNextScreen()
                }
            },
            onBack: {
                viewModel.moveToPreviousScreen()
            }
        ) {
            VStack(spacing: 24) {
                DatePicker("Select Time", selection: $viewModel.selections.reminderTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .accentColor(.brandPrimary)
                    .background(Color.baseBlack)
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
            subtitle: OnboardingScreen.moodCheck.subtitle,
            progress: 0.6,
            isNextButtonEnabled: true,
            nextButtonTitle: "Continue",
            onNext: {
                viewModel.moveToNextScreen()
            },
            onBack: {
                viewModel.moveToPreviousScreen()
            }
        ) {
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
    
    func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
        // Set flag and continue regardless of whether review was shown
        hasRequestedReview = true
    }
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.resetPlan.title,
            subtitle: OnboardingScreen.resetPlan.subtitle,
            progress: 0.7,
            isNextButtonEnabled: true,
            nextButtonTitle: "Start Day 1 Now",
            onNext: {
                if !hasRequestedReview {
                    requestReview()
                } else {
                    viewModel.moveToNextScreen()
                }
            },
            onBack: {
                viewModel.moveToPreviousScreen()
            }
        ) {
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
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.brandPrimary)
            
            Text(title)
                .font(.system(size: 17, weight: .regular))
                .foregroundColor(.baseWhite)
            
            Spacer()
            
            Image(systemName: isLocked ? "lock.fill" : "checkmark.circle.fill")
                .foregroundColor(isLocked ? .baseWhite.opacity(0.3) : .brandPrimary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .glassmorphism()
    }
}

// MARK: - Breathing Exercise Screen

struct BreathingExerciseScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isInhaling = false
    @State private var cyclesCompleted = 0
    @State private var fillAmount: CGFloat = 0
    @State private var showExhalePrompt = false
    @State private var isExhaling = false
    let totalCycles = 3
    
    var instructionText: String {
        if isExhaling {
            return "Release and exhale through your mouth"
        }
        if !isInhaling {
            return "Hold the button and inhale through your nose"
        }
        return showExhalePrompt ? "Release and exhale through your mouth" : "Hold the button and inhale through your nose"
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.baseBlack.ignoresSafeArea()
                
                // Purple fill overlay
                Color.brandPrimary
                    .opacity(0.3)
                    .frame(height: geometry.size.height * fillAmount)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .animation(.easeInOut(duration: 7), value: fillAmount)
                
                VStack(alignment: .leading, spacing: 0) {
                    // Top Navigation Bar
                    HStack(spacing: 16) {
                        Button(action: { viewModel.moveToPreviousScreen() }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.baseWhite)
                        }
                        
                        GeometryReader { barGeometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.baseWhite.opacity(0.1))
                                    .frame(height: 4)
                                    .cornerRadius(2)
                                
                                Rectangle()
                                    .fill(Color.baseWhite)
                                    .frame(width: barGeometry.size.width * 0.8, height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(height: 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // Title and Subtitle
                    VStack(alignment: .leading, spacing: 12) {
                        Text(OnboardingScreen.breathingExercise.title)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.baseWhite)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text(OnboardingScreen.breathingExercise.subtitle)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.baseWhite.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 32)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Breathing Instructions
                    Text(instructionText)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.baseWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 32)
                        .animation(.easeInOut, value: instructionText)
                    
                    // Progress Text
                    Text("\(cyclesCompleted)/\(totalCycles) breaths completed")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.baseWhite.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)
                    
                    // Touch Circle
                    ZStack {
                        Circle()
                            .stroke(Color.brandPrimary.opacity(0.3), lineWidth: 2)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(Color.brandPrimary.opacity(isInhaling ? 0.3 : 0.15))
                            .frame(width: 80, height: 80)
                        
                        Text("Hold")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.baseWhite)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 50)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isInhaling {
                                    isInhaling = true
                                    isExhaling = false
                                    showExhalePrompt = false
                                    withAnimation {
                                        fillAmount = 0.85
                                    }
                                    // Schedule the exhale prompt to appear when fill reaches top
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                                        showExhalePrompt = true
                                    }
                                }
                            }
                            .onEnded { _ in
                                isInhaling = false
                                isExhaling = true
                                withAnimation {
                                    fillAmount = 0
                                }
                                
                                // Wait for exhale animation to complete before resetting prompt and counting the breath
                                DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                                    isExhaling = false
                                    showExhalePrompt = false
                                    cyclesCompleted += 1
                                    if cyclesCompleted >= totalCycles {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            viewModel.moveToNextScreen()
                                        }
                                    }
                                }
                            }
                    )
                }
            }
        }
    }
}

// MARK: - Breathing Completion Screen

struct BreathingCompletionScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var isBreathing = false
    
    var body: some View {
        OnboardingScreenContainer(
            title: "",
            subtitle: "",
            progress: 0.8,
            isNextButtonEnabled: true,
            nextButtonTitle: "Continue",
            onNext: {
                viewModel.moveToNextScreen()
            },
            onBack: {
                viewModel.moveToPreviousScreen()
            }
        ) {
            // Center content with circle background
            ZStack {
                // Soft breathing circle
                Circle()
                    .fill(Color.brandPrimary.opacity(0.15))
                    .scaleEffect(isBreathing ? 1.1 : 1.0)
                    .animation(
                        Animation
                            .easeInOut(duration: 4)
                            .repeatForever(autoreverses: true),
                        value: isBreathing
                    )
                
                // Text content
                VStack(spacing: 24) {
                    Text("Reset complete.")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.baseWhite)
                        .multilineTextAlignment(.center)
                    
                    Text("Your body felt that. Just 3 breaths made a difference.")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.baseWhite.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    Text("You're 1 step into your reset plan. Let's keep your momentum going.")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.baseWhite.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
                .opacity(isBreathing ? 1 : 0)
                .animation(.easeIn.delay(0.3), value: isBreathing)
            }
            .frame(maxHeight: .infinity)
        }
        .onAppear {
            withAnimation {
                isBreathing = true
            }
        }
    }
}

// MARK: - Progress Screen

struct ProgressScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let onCompletion: () -> Void
    
    var body: some View {
        OnboardingScreenContainer(
            title: OnboardingScreen.progress.title,
            subtitle: OnboardingScreen.progress.subtitle,
            progress: 0.9,
            isNextButtonEnabled: true,
            nextButtonTitle: "Unlock Full Plan",
            onNext: {
                onCompletion()
            },
            onBack: {
                viewModel.moveToPreviousScreen()
            }
        ) {
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
                    .cornerRadius(8)
                
                Rectangle()
                    .fill(Color.brandPrimary)
                    .frame(width: geometry.size.width * progress)
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - Previews
struct OnboardingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Full Onboarding Flow
            OnboardingView { }
                .previewDisplayName("Full Onboarding Flow")
            
            // Individual Screens
            Group {
                WelcomeScreen(viewModel: OnboardingViewModel())
                    .previewDisplayName("Welcome")
                
                MotivationScreen(viewModel: OnboardingViewModel())
                    .previewDisplayName("Motivation")
                
                TensionAreasScreen(viewModel: OnboardingViewModel())
                    .previewDisplayName("Tension Areas")
                
                TimeCommitmentScreen(viewModel: OnboardingViewModel())
                    .previewDisplayName("Time Commitment")
                
                ReminderScreen(viewModel: OnboardingViewModel())
                    .previewDisplayName("Reminder")
                
                MoodCheckScreen(viewModel: OnboardingViewModel())
                    .previewDisplayName("Mood Check")
                
                ResetPlanScreen(viewModel: OnboardingViewModel())
                    .previewDisplayName("Reset Plan")
                
                BreathingExerciseScreen(viewModel: OnboardingViewModel())
                    .previewDisplayName("Breathing Exercise")
                
                BreathingCompletionScreen(viewModel: OnboardingViewModel())
                    .previewDisplayName("Breathing Completion")
                
                ProgressScreen(viewModel: OnboardingViewModel()) {
                    // Placeholder for onCompletion
                }
                    .previewDisplayName("Progress")
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    WelcomeScreen(viewModel: OnboardingViewModel())
} 