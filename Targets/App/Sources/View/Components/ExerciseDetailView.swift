import SwiftUI
import SharedKit

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Thumbnail Image
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.brandPrimary.opacity(0.1),
                                        Color.brandPrimary.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(Color.brandPrimary.opacity(0.2), lineWidth: 1)
                            )
                        
                        Image(exercise.thumbnailName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(32)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    
                    VStack(spacing: 32) {
                        // Title and Duration
                        VStack(alignment: .leading, spacing: 8) {
                            Text(exercise.name)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(exercise.duration / 60) min")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // Instructions Section
                        VStack(alignment: .leading, spacing: 24) {
                            Text("INSTRUCTIONS")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.horizontal)
                            
                            TimelineView(items: exercise.instructions.components(separatedBy: "\n"))
                        }
                        
                        // Modifications Section
                        if let modifications = exercise.modifications?.components(separatedBy: "\n") {
                            VStack(alignment: .leading, spacing: 24) {
                                Text("MODIFICATIONS")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                                    .textCase(.uppercase)
                                    .padding(.horizontal)
                                
                                TimelineView(items: modifications)
                            }
                        }
                        
                        // Benefits Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("BENEFITS")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.horizontal)
                            
                            Text(exercise.benefits)
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                                .lineSpacing(4)
                                .padding(.horizontal)
                        }
                        
                        // Areas Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("AREAS")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.horizontal)
                            
                            Text(exercise.areas.map(\.rawValue).joined(separator: ", "))
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
    ExerciseDetailView(exercise: ExerciseLibrary.exercises.first!)
        .preferredColorScheme(.dark)
} 