import SwiftUI
import SharedKit

struct PlanDetailView: View {
    let title: String
    let description: String
    let duration: String // e.g., "3 DAY SERIES"
    let routines: [Routine]
    @State private var selectedRoutineForPreview: Routine?
    
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
                            Button(action: { selectedRoutineForPreview = routine }) {
                                PlanRoutineRow(
                                    routine: routine,
                                    dayNumber: index + 1
                                )
                            }
                        }
                    }
                    .padding()
                }
                
                // Select Plan Button
                NavigationLink(destination: RoutineDetailView(routine: routines[0])) {
                    Text("SELECT PLAN")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brandPrimary)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedRoutineForPreview) { routine in
            NavigationView {
                RoutineDetailView(
                    routine: routine,
                    previewMode: true
                )
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
            Image(routine.thumbnailName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(routine.totalDuration / 60) min")
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
            routines: Array(RoutineLibrary.routines.prefix(3))
        )
    }
    .preferredColorScheme(.dark)
} 