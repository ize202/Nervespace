import SwiftUI
import SharedKit

struct SessionCard: View {
    let title: String
    let duration: String
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(duration)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(width: 160)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor.opacity(0.1))
        )
    }
}

#Preview {
    SessionCard(
        title: "Wake Up",
        duration: "5 MINUTES",
        backgroundColor: .brandPrimary
    )
} 