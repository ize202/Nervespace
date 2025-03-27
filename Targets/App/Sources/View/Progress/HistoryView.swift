import SwiftUI
import SupabaseKit

struct CompletedRoutine: Identifiable {
    let id: UUID
    let routineName: String
    let date: Date
    let duration: Int // in seconds
    let exercises: [Exercise]
    let thumbnailURL: URL?
}

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    // Mock data for now - would come from database
    @State private var completedRoutines: [CompletedRoutine] = [
        CompletedRoutine(
            id: UUID(),
            routineName: "Morning Reset",
            date: Date(),
            duration: 900,
            exercises: [],
            thumbnailURL: nil
        ),
        CompletedRoutine(
            id: UUID(),
            routineName: "Evening Unwind",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            duration: 600,
            exercises: [],
            thumbnailURL: nil
        )
    ]
    
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
                                ForEach(routines) { routine in
                                    Button(action: {
                                        // TODO: Show detailed view of completed routine
                                    }) {
                                        HStack(spacing: 16) {
                                            // Thumbnail
                                            if let thumbnailURL = routine.thumbnailURL {
                                                AsyncImage(url: thumbnailURL) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                } placeholder: {
                                                    Color.white.opacity(0.1)
                                                }
                                                .frame(width: 44, height: 44)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            } else {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.white.opacity(0.1))
                                                    .frame(width: 44, height: 44)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(routine.routineName)
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                
                                                Text("\(timeFormatter.string(from: routine.date)) • \(routine.duration / 60) min")
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        // TODO: Filter by routine type
                    }) {
                        Label("Filter by Type", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    Button(action: {
                        // TODO: Export history
                    }) {
                        Label("Export History", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
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