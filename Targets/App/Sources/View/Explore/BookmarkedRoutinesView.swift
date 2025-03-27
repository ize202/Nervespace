import SwiftUI
import SupabaseKit

struct BookmarkedRoutinesView: View {
    @State private var bookmarkedRoutines: [(Routine, [Exercise])] = [
        // Mock data for now - would come from database/user defaults
        (Routine.mockWakeAndShake, Dictionary.mockRoutineExercises[Routine.mockWakeAndShake.id] ?? []),
        (Routine.mockEveningUnwind, Dictionary.mockRoutineExercises[Routine.mockEveningUnwind.id] ?? [])
    ]
    
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
                        ForEach(bookmarkedRoutines, id: \.0.id) { routine, exercises in
                            NavigationLink(destination: RoutineDetailView(routine: routine, exercises: exercises)) {
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
                                        .frame(width: 56, height: 56)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 56, height: 56)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(routine.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("\(exercises.count) exercises • \(exercises.reduce(0) { $0 + $1.baseDuration } / 60) min")
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