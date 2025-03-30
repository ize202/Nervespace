import SwiftUI
import SharedKit

struct CompletedRoutine: Identifiable {
    let id: UUID
    let routine: Routine
    let date: Date
}

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var completedRoutines: [CompletedRoutine] = []
    
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
    
    private var groupedRoutines: [(String, [CompletedRoutine])] {
        let grouped = Dictionary(grouping: completedRoutines) { routine in
            if Calendar.current.isDateInToday(routine.date) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(routine.date) {
                return "Yesterday"
            } else {
                return dateFormatter.string(from: routine.date)
            }
        }
        return grouped.sorted { lhs, rhs in
            let lhsDate = completedRoutines.first { routine in
                if Calendar.current.isDateInToday(routine.date) {
                    return lhs.key == "Today"
                } else if Calendar.current.isDateInYesterday(routine.date) {
                    return lhs.key == "Yesterday"
                } else {
                    return dateFormatter.string(from: routine.date) == lhs.key
                }
            }?.date ?? Date.distantPast
            
            let rhsDate = completedRoutines.first { routine in
                if Calendar.current.isDateInToday(routine.date) {
                    return rhs.key == "Today"
                } else if Calendar.current.isDateInYesterday(routine.date) {
                    return rhs.key == "Yesterday"
                } else {
                    return dateFormatter.string(from: routine.date) == rhs.key
                }
            }?.date ?? Date.distantPast
            
            return lhsDate > rhsDate
        }
    }
    
    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(groupedRoutines, id: \.0) { date, routines in
                        VStack(alignment: .leading, spacing: 16) {
                            // Date Header
                            Text(date)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Routines for this date
                            VStack(spacing: 12) {
                                ForEach(routines) { completed in
                                    NavigationLink(destination: RoutineDetailView(routine: completed.routine)) {
                                        HStack(spacing: 16) {
                                            // Thumbnail
                                            Image(completed.routine.thumbnailName)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 44, height: 44)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(completed.routine.name)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                
                                                Text("\(timeFormatter.string(from: completed.date)) • \(completed.routine.totalDuration / 60) min")
                                                    .font(.subheadline)
                                                    .foregroundColor(.white.opacity(0.6))
                                            }
                                            
                                            Spacer()
                                            
                                            // Checkmark
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.brandPrimary)
                                                .frame(width: 44, height: 44)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.ultraThinMaterial)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("History")
        .onAppear {
            // For preview purposes, we'll add some sample completed routines
            // In production, this would be loaded from UserDefaults or a database
            if completedRoutines.isEmpty {
                let routines = Array(RoutineLibrary.routines.prefix(2))
                completedRoutines = [
                    CompletedRoutine(
                        id: UUID(),
                        routine: routines[0],
                        date: Date()
                    ),
                    CompletedRoutine(
                        id: UUID(),
                        routine: routines[1],
                        date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
                    )
                ]
            }
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .preferredColorScheme(.dark)
} 