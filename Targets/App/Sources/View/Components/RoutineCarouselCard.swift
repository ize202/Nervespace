import SwiftUI
import SharedKit

struct RoutineCarouselCard: View {
    let title: String
    let duration: String
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(duration)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.8)
            
            // Placeholder for exercise icons - we'll implement this later
            Circle()
                .fill(Color.brandPrimary.opacity(0.2))
                .frame(height: 120)
        }
        .frame(width: UIScreen.main.bounds.width - 48)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemGray6))
        )
        .scaleEffect(isSelected ? 1 : 0.9)
        .opacity(isSelected ? 1 : 0.6)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    RoutineCarouselCard(
        title: "Wake Up",
        duration: "5 MINUTES",
        isSelected: true
    )
} 