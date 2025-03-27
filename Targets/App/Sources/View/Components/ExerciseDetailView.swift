import SwiftUI
import SupabaseKit

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Thumbnail/Video Area
                    Group {
                        if let previewURL = exercise.previewURL {
                            AsyncImage(url: previewURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                        } else {
                            Color.gray.opacity(0.2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                    
                    VStack(spacing: 32) {
                        // Title and Duration
                        VStack(alignment: .leading, spacing: 8) {
                            Text(exercise.name)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(exercise.baseDuration / 60) min")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // Instructions Section
                        if let instructions = exercise.instructions?.components(separatedBy: "\n") {
                            VStack(alignment: .leading, spacing: 24) {
                                Text("INSTRUCTIONS")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .textCase(.uppercase)
                                    .padding(.horizontal)
                                
                                TimelineView(items: instructions)
                            }
                        }
                        
                        // Modifications Section
                        VStack(alignment: .leading, spacing: 24) {
                            Text("MODIFICATIONS")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.horizontal)
                            
                            TimelineView(items: [
                                "For less intensity, keep your hands on your front thigh.",
                                "Place a towel or cushion under your back knee for support.",
                                "Hold onto a wall or chair for balance if needed."
                            ])
                        }
                        
                        // Benefits Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("BENEFITS")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.horizontal)
                            
                            Text("Abdomen, Hips, Lower Back, Psoas, Quadriceps")
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .lineSpacing(4)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

private struct TimelineView: View {
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 12) {
                    // Step indicator
                    ZStack {
                        Circle()
                            .fill(Color.brandPrimary.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.brandPrimary)
                    }
                    
                    Text(item)
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .lineSpacing(4)
                        .padding(.top, 6)
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ExerciseDetailView(exercise: .mockDynamicSideBends)
        .preferredColorScheme(.dark)
} 