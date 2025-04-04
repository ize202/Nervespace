import SwiftUI
import SharedKit
import SupabaseKit

struct CompletedRoutine: Identifiable {
    let id: UUID
    let routine: Routine
    let date: Date
    let durationMinutes: Int
    
    init(completion: Model.RoutineCompletion) {
        self.id = completion.id
        self.routine = RoutineLibrary.routines.first { $0.id == completion.routineId } ?? RoutineLibrary.routines[0]
        self.date = completion.completedAt
        self.durationMinutes = completion.durationMinutes
    }
}

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: HistoryViewModel
    
    init(completionStore: RoutineCompletionStore, syncManager: SupabaseSyncManager) {
        _viewModel = StateObject(wrappedValue: HistoryViewModel(
            completionStore: completionStore,
            syncManager: syncManager
        ))
    }
    
    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()
            
            if viewModel.completedRoutines.isEmpty {
                EmptyHistoryView()
            } else {
                HistoryListView(viewModel: viewModel)
            }
            
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("History")
        .task {
            await viewModel.refresh()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

// MARK: - Empty State View
private struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("No History Yet")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            Text("Complete your first routine to start tracking your progress!")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - History List View
private struct HistoryListView: View {
    @ObservedObject var viewModel: HistoryViewModel
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.groupedRoutines(), id: \.0) { date, routines in
                    HistoryDaySection(
                        date: date,
                        routines: routines,
                        timeFormatter: timeFormatter,
                        onDelete: { id in
                            Task {
                                await viewModel.deleteCompletion(id: id)
                            }
                        }
                    )
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - History Day Section
private struct HistoryDaySection: View {
    let date: String
    let routines: [CompletedRoutine]
    let timeFormatter: DateFormatter
    let onDelete: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(date)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            ForEach(routines) { routine in
                HistoryRoutineRow(
                    routine: routine,
                    timeFormatter: timeFormatter,
                    onDelete: { onDelete(routine.id) }
                )
            }
        }
    }
}

// MARK: - History Routine Row
private struct HistoryRoutineRow: View {
    let routine: CompletedRoutine
    let timeFormatter: DateFormatter
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.routine.name)
                    .font(.body)
                    .foregroundColor(.white)
                
                Text(timeFormatter.string(from: routine.date))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Text("\(routine.durationMinutes)m")
                .font(.body)
                .foregroundColor(.brandPrimary)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
        .swipeActions {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView(
            completionStore: RoutineCompletionStore(),
            syncManager: SupabaseSyncManager(
                db: DB(),
                progressStore: LocalProgressStore(),
                completionStore: RoutineCompletionStore(),
                pendingStore: PendingCompletionStore()
            )
        )
    }
} 