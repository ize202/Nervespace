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
                .foregroundStyle(Color.baseBlack)
                .minimumScaleFactor(0.8)
            
            // Placeholder for exercise icons - we'll implement this later
            Circle()
                .fill(Color.brandPrimary.opacity(0.2))
                .frame(height: 160)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.baseGray)
        )
    }
}

#Preview {
    RoutineCarouselCard(
        title: "Wake Up",
        duration: "5 MINUTES",
        isSelected: true
    )
} 