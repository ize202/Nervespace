import SwiftUI
import SharedKit

struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let goal: Int
    let current: Int
    
    private let lineWidth: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.baseBlack.opacity(0.1),
                    lineWidth: lineWidth
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    Color.brandSecondary,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
            
            // Center content
            VStack(spacing: 4) {
                Text("\(current)/\(goal)")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.baseBlack)
                
                Text("CAL")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.baseBlack.opacity(0.7))
            }
        }
    }
}

#Preview {
    VStack {
        CircularProgressView(progress: 0.75, goal: 300, current: 225)
            .frame(width: 200, height: 200)
            .padding()
            .background(Color.baseGray)
            .cornerRadius(16)
        
        CircularProgressView(progress: 0.25, goal: 300, current: 75)
            .frame(width: 200, height: 200)
            .padding()
            .background(Color.baseGray)
            .cornerRadius(16)
    }
} 