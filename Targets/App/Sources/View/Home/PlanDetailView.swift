import SwiftUI
import SupabaseKit

struct PlanDetailView: View {
    let title: String
    let description: String
    let duration: String // e.g., "3 DAY SERIES"
    let routines: [Routine]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.baseBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(duration)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .textCase(.uppercase)
                    
                    Text(description)
                        .font(.system(size: 17))
                        .foregroundColor(.white.opacity(0.7))
                        .lineSpacing(4)
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 24)
                
                // Routines List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(routines.enumerated()), id: \.element.id) { index, routine in
                            NavigationLink(destination: RoutineDetailView(routine: routine, exercises: [])) {
                                PlanRoutineRow(
                                    routine: routine,
                                    dayNumber: index + 1
                                )
                            }
                        }
                    }
                    .padding()
                }
                
                // Continue Button
                Button(action: {
                    // TODO: Start plan
                }) {
                    Text("CONTINUE")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(white: 0.3))
                        .cornerRadius(12)
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
                }
            }
        }
    }
}

struct PlanRoutineRow: View {
    let routine: Routine
    let dayNumber: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail
            if let thumbnailURL = routine.thumbnailURL {
                AsyncImage(url: thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 56, height: 56)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("5 MINUTES")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Day Number
            Text("DAY \(dayNumber)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        }
    }
}

#Preview {
    NavigationView {
        PlanDetailView(
            title: "Beginner",
            description: "A beginner series designed to increase overall flexibility by covering key areas throughout your entire body.",
            duration: "3 DAY SERIES",
            routines: [
                .mockWakeAndShake,
                .mockEveningUnwind,
                .mockQuickReset
            ]
        )
    }
    .preferredColorScheme(.dark)
} 