import SwiftUI
import SharedKit

struct CircularProgressView: View {
    let progress: Double // 0.0 to 1.0
    let goal: Int
    let current: Int
    
    private let lineWidth: CGFloat = 30
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: lineWidth
                )
            
            // Progress ring
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    Color.brandPrimary,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
            
            // Center content
            VStack(spacing: 8) {
                Text("\(current)/\(goal)")
                    .font(.system(size: 34, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                Text("minutes")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(lineWidth/2)
    }
}

#Preview {
    VStack(spacing: 20) {
        CircularProgressView(progress: 0.75, goal: 300, current: 225)
            .frame(width: 250, height: 250)
            .padding()
            .background(Color.baseGray)
            .cornerRadius(16)
        
        CircularProgressView(progress: 0.163, goal: 300, current: 49)
            .frame(width: 250, height: 250)
            .padding()
            .background(Color.baseGray)
            .cornerRadius(16)
    }
} 