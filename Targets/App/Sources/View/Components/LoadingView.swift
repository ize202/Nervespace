import SwiftUI

struct LoadingView: View {
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.brandPrimary, lineWidth: 2)
            .frame(width: 24, height: 24)
            .rotationEffect(Angle(degrees: 360), anchor: .center)
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
    }
}

struct LoadingOverlay: View {
    var body: some View {
        LoadingView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.2))
    }
}

#Preview {
    VStack(spacing: 20) {
        LoadingView()
        
        LoadingOverlay()
    }
    .frame(width: 300, height: 300)
    .background(Color.baseBlack)
} 