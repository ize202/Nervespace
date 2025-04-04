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
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(viewModel.groupedRoutines(), id: \.0) { date, routines in
                            // Date Header
                            Text(date)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Routines for this date
                            VStack(spacing: 12) {
                                ForEach(routines) { completed in
                                    HStack(spacing: 16) {
                                        // Thumbnail
                                        Image(completed.routine.thumbnailName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 56, height: 56)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(completed.routine.name)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Text("\(completed.routine.exercises.count) exercises • \(completed.durationMinutes) min")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                        
                                        Spacer()
                                        
                                        Text(timeFormatter.string(from: completed.date))
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    .padding()
                                    .background {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await viewModel.refresh()
                }
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
    }
}

#Preview {
    NavigationStack {
        HistoryView(completionStore: RoutineCompletionStore(), syncManager: SupabaseSyncManager())
    }
    .preferredColorScheme(.dark)
} 
} 