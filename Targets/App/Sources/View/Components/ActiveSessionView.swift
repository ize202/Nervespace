import SwiftUI
import SupabaseKit

public struct ActiveSessionView: View {
    let routine: Routine
    let exercises: [Exercise]
    let customDurations: [UUID: Int]
    @State private var currentExerciseIndex: Int = 0
    @State private var timeRemaining: Int
    @State private var isPaused: Bool = false
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    public init(routine: Routine, exercises: [Exercise], customDurations: [UUID: Int]) {
        self.routine = routine
        self.exercises = exercises
        self.customDurations = customDurations
        // Initialize with the first exercise duration
        _timeRemaining = State(initialValue: exercises.first.map { customDurations[$0.id] ?? $0.baseDuration } ?? 30)
    }
    
    private var currentExercise: Exercise? {
        guard exercises.indices.contains(currentExerciseIndex) else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    private var progressText: String {
        "\(currentExerciseIndex + 1) of \(exercises.count)"
    }
    
    public var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text(progressText)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // TODO: Show more options
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Exercise Animation/Image
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 4)
                        .frame(width: 280, height: 280)
                    
                    if let thumbnailURL = currentExercise?.thumbnailURL {
                        AsyncImage(url: thumbnailURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 260, height: 260)
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 260, height: 260)
                        }
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 260, height: 260)
                    }
                    
                    // Switch sides indicator
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(Circle().fill(Color.black.opacity(0.6)))
                        .position(x: 280 * 0.5 + 24, y: 280 * 0.5)
                }
                
                // Exercise Name
                HStack {
                    Text(currentExercise?.name ?? "")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Button(action: {
                        // TODO: Show exercise info
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // Timer
                Text(timeString(from: timeRemaining))
                    .font(.system(size: 72, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.top, 32)
                
                Spacer()
                
                // Playback Controls
                HStack(spacing: 40) {
                    Button(action: previousExercise) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    
                    Button(action: togglePause) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    
                    Button(action: nextExercise) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                }
                .padding(.bottom, 48)
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard !isPaused else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // Time's up for current exercise
                if currentExerciseIndex < exercises.count - 1 {
                    // Move to next exercise
                    nextExercise()
                } else {
                    // Workout complete
                    timer?.invalidate()
                    timer = nil
                    // TODO: Show workout complete screen
                    dismiss()
                }
            }
        }
    }
    
    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
            timer = nil
        } else {
            startTimer()
        }
    }
    
    private func nextExercise() {
        guard currentExerciseIndex < exercises.count - 1 else { return }
        currentExerciseIndex += 1
        timeRemaining = customDurations[exercises[currentExerciseIndex].id] ?? exercises[currentExerciseIndex].baseDuration
    }
    
    private func previousExercise() {
        guard currentExerciseIndex > 0 else { return }
        currentExerciseIndex -= 1
        timeRemaining = customDurations[exercises[currentExerciseIndex].id] ?? exercises[currentExerciseIndex].baseDuration
    }
}

#Preview {
    ActiveSessionView(
        routine: .mockWakeAndShake,
        exercises: Dictionary.mockRoutineExercises[Routine.mockWakeAndShake.id] ?? [],
        customDurations: [:]
    )
} 