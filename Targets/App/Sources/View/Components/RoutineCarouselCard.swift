import SwiftUI
import SharedKit

struct RoutineCarouselCard: View {
    let title: String
    let duration: String
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(duration)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.8)
            
            // Placeholder for exercise icons - we'll implement this later
            Circle()
                .fill(Color.brandPrimary.opacity(0.2))
                .frame(height: 160)
        }
        .frame(width: UIScreen.main.bounds.width * 0.85)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGray6))
        )
        .scaleEffect(isSelected ? 1 : 0.85)
        .opacity(isSelected ? 1 : 0.5)
    }
}

#Preview {
    RoutineCarouselCard(
        title: "Wake Up",
        duration: "5 MINUTES",
        isSelected: true
    )
} 