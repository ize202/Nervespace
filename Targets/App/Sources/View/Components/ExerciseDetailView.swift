import SwiftUI
import SupabaseKit

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.baseBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview/Animation
                        if let previewURL = exercise.previewURL {
                            AsyncImage(url: previewURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Header Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(exercise.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(exercise.baseDuration / 60) MINUTES")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)
                            
                            if let description = exercise.description {
                                Text(description)
                                    .font(.system(size: 17))
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineSpacing(4)
                                    .padding(.top, 4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Instructions
                        if let instructions = exercise.instructions {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Instructions")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Text(instructions)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.7))
                                    .lineSpacing(4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Add to favorites
                    }) {
                        Image(systemName: "bookmark")
                            .foregroundColor(.brandPrimary)
                            .font(.system(size: 20))
                    }
                }
            }
        }
    }
}

#Preview {
    ExerciseDetailView(exercise: .mockDynamicSideBends)
        .preferredColorScheme(.dark)
} 