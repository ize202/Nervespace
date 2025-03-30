import SwiftUI
import SharedKit

// Import models
@_exported import struct SharedKit.Routine
@_exported import struct SharedKit.Exercise
@_exported import struct SharedKit.RoutineExercise

struct BookmarkedRoutinesView: View {
    @StateObject private var bookmarkManager = BookmarkManager.shared
    
    private var bookmarkedRoutines: [Routine] {
        bookmarkManager.getBookmarkedRoutines()
    }
    
    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()
            
            if bookmarkedRoutines.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("No Bookmarked Routines")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Routines you bookmark will appear here")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(bookmarkedRoutines) { routine in
                            NavigationLink(destination: RoutineDetailView(routine: routine)) {
                                HStack(spacing: 16) {
                                    // Thumbnail
                                    Image(routine.thumbnailName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(routine.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("\(routine.exercises.count) exercises • \(routine.totalDuration / 60) min")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Bookmarks")
    }
}

#Preview {
    NavigationStack {
        BookmarkedRoutinesView()
    }
    .preferredColorScheme(.dark)
} 