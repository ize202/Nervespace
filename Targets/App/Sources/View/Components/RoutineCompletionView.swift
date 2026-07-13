import LocalDataKit
import SharedKit
import SwiftUI

struct RoutineCompletionView: View {
    let completion: LocalDataKit.RoutineCompletion
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var activityStore: LocalActivityStore
    @State private var showConfetti = false

    private let weekDays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    private let calendar = Calendar.current

    private var routine: Routine? {
        RoutineLibrary.routine(id: completion.routineID)
    }

    private var currentStreak: Int {
        activityStore.progress.currentStreak
    }

    private var isStreakMilestone: Bool {
        currentStreak <= 1 || currentStreak.isMultiple(of: 7)
    }

    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    header
                    streakCard
                    completedRoutineCard
                    continueButton
                }
                .padding(.vertical)
            }

            if showConfetti {
                ConfettiView(intensity: isStreakMilestone ? .high : .low)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
        }
        .presentationBackground(.clear)
        .presentationDragIndicator(.visible)
        .presentationDetents([.large])
        .onAppear {
            showConfetti = true
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Congrats!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("You completed your daily routine.")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal)
    }

    private var streakCard: some View {
        VStack(spacing: 16) {
            Text("\(currentStreak) day")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)

            Text("ACTIVE STREAK")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.6))

            HStack(spacing: 20) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { _, day in
                    VStack(spacing: 8) {
                        Text(day)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.6))

                        Circle()
                            .fill(
                                isToday(day)
                                    ? .white.opacity(0.2)
                                    : Color.white.opacity(0.1)
                            )
                            .frame(width: 32, height: 32)
                            .overlay {
                                if isToday(day) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var completedRoutineCard: some View {
        HStack(spacing: 16) {
            if let routine {
                Image(routine.thumbnailName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "questionmark.square.dashed")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 56, height: 56)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(routine?.name ?? "Unavailable routine")
                    .font(.headline)
                    .foregroundColor(.white)

                if let routine {
                    Text(
                        "\(routine.exercises.count) exercises • "
                            + "\(completion.durationMinutes) min"
                    )
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                } else {
                    Text(completion.routineID)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.55))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(completion.durationMinutes) min")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Spacer()

            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private var continueButton: some View {
        Button {
            dismiss()
            onComplete()
        } label: {
            Text("CONTINUE")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.brandPrimary)
                .cornerRadius(12)
        }
        .accessibilityIdentifier(AccessibilityIdentifier.saveCompletion)
        .padding(.horizontal)
        .padding(.bottom, 32)
    }

    private func isToday(_ day: String) -> Bool {
        guard let index = weekDays.firstIndex(of: day) else {
            return false
        }
        let today = calendar.component(.weekday, from: Date())
        let adjustedToday = today == 1 ? 7 : today - 1
        return index + 1 == adjustedToday
    }
}

struct ConfettiView: View {
    enum Intensity {
        case low
        case high

        var pieceCount: Int {
            switch self {
            case .low: 20
            case .high: 50
            }
        }

        var duration: Double {
            switch self {
            case .low: 2
            case .high: 3
            }
        }

        var delayRange: Double {
            switch self {
            case .low: 0.5
            case .high: 1
            }
        }
    }

    let intensity: Intensity
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<intensity.pieceCount, id: \.self) { _ in
                    ConfettiPiece()
                        .position(
                            x: .random(in: 0...geometry.size.width),
                            y: isAnimating ? geometry.size.height + 100 : -100
                        )
                        .animation(
                            .linear(duration: intensity.duration)
                                .repeatForever(autoreverses: false)
                                .delay(.random(in: 0...intensity.delayRange)),
                            value: isAnimating
                        )
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

private struct ConfettiPiece: View {
    private let colors: [Color] = [
        .brandPrimary,
        .blue,
        .green,
        .yellow,
        .pink,
        .purple,
        .orange,
    ]

    var body: some View {
        Circle()
            .fill(colors.randomElement() ?? .brandPrimary)
            .frame(width: 10, height: 10)
            .rotation3DEffect(
                .degrees(.random(in: -360...360)),
                axis: (
                    x: .random(in: 0...1),
                    y: .random(in: 0...1),
                    z: .random(in: 0...1)
                )
            )
    }
}

#Preview {
    let routine = RoutineLibrary.routines[0]
    let completion = LocalDataKit.RoutineCompletion(
        id: UUID(),
        routineID: routine.id,
        durationMinutes: 7,
        completedAt: Date()
    )

    RoutineCompletionView(completion: completion, onComplete: {})
        .environmentObject(makePreviewActivityStore())
}
