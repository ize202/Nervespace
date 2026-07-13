import LocalDataKit
import SharedKit
import SwiftUI

private struct CompletedRoutine: Identifiable {
    let completion: LocalDataKit.RoutineCompletion
    let routine: Routine?

    var id: UUID { completion.id }
}

struct HistoryView: View {
    @EnvironmentObject private var activityStore: LocalActivityStore
    @State private var errorMessage: String?

    private let calendar = Calendar.current

    private var sections: [CompletionDay] {
        CompletionHistory.sections(
            from: activityStore.completions,
            calendar: calendar,
            rolloverHour: 4
        )
    }

    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()

            if sections.isEmpty {
                EmptyHistoryView()
            } else {
                HistoryListView(
                    sections: sections,
                    onDelete: deleteCompletion
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("History")
        .alert("Unable to Delete Completion", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }

    private func deleteCompletion(id: UUID) {
        do {
            try activityStore.deleteCompletion(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("No History Yet")
                .font(.title2)
                .bold()
                .foregroundColor(.white)

            Text("Complete your first routine to start tracking your progress.")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

private struct HistoryListView: View {
    let sections: [CompletionDay]
    let onDelete: (UUID) -> Void

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()

    var body: some View {
        List {
            ForEach(sections, id: \.activityDay) { section in
                Section {
                    ForEach(section.completions) { completion in
                        HistoryRoutineRow(
                            item: CompletedRoutine(
                                completion: completion,
                                routine: RoutineLibrary.routine(id: completion.routineID)
                            ),
                            onDelete: { onDelete(completion.id) }
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                } header: {
                    Text(dateFormatter.string(from: section.activityDay))
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .listStyle(.plain)
        .background(Color.baseBlack)
    }
}

private struct HistoryRoutineRow: View {
    let item: CompletedRoutine
    let onDelete: () -> Void

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    var body: some View {
        HStack(spacing: 12) {
            if let routine = item.routine {
                Image(routine.thumbnailName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "questionmark.square.dashed")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 44, height: 44)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.routine?.name ?? "Unavailable routine")
                    .font(.body)
                    .foregroundColor(.white)

                if item.routine == nil {
                    Text(item.completion.routineID)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.55))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(timeFormatter.string(from: item.completion.completedAt))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Text("\(item.completion.durationMinutes)m")
                .font(.body)
                .foregroundColor(.brandPrimary)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityIdentifier.historyRow)
        .swipeActions {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .environmentObject(makePreviewActivityStore())
    }
}
