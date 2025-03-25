import SwiftUI

struct SnapCarousel<Content: View>: View {
    let items: [(String, String)]
    @ViewBuilder let content: (String, String, Bool) -> Content
    @State private var currentIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    private let cardWidth: CGFloat = UIScreen.main.bounds.width * 0.75
    private let cardSpacing: CGFloat = 24
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: cardSpacing) {
                ForEach(items.indices, id: \.self) { index in
                    content(items[index].0, items[index].1, currentIndex == index)
                        .frame(width: cardWidth)
                }
            }
            .offset(x: calculateOffset(geometry))
            .animation(.interpolatingSpring(stiffness: 100, damping: 12), value: dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = cardWidth * 0.15
                        var newIndex = currentIndex
                        
                        if abs(value.translation.width) > threshold {
                            newIndex = value.translation.width > 0 ? currentIndex - 1 : currentIndex + 1
                        }
                        
                        newIndex = min(max(newIndex, 0), items.count - 1)
                        withAnimation(.interpolatingSpring(stiffness: 100, damping: 12)) {
                            currentIndex = newIndex
                        }
                    }
            )
        }
    }
    
    private func calculateOffset(_ geometry: GeometryProxy) -> CGFloat {
        let totalSpacing = cardSpacing * CGFloat(items.count - 1)
        let totalWidth = cardWidth * CGFloat(items.count) + totalSpacing
        let screenWidth = geometry.size.width
        let initialOffset = (screenWidth - cardWidth) / 2
        let contentOffset = -CGFloat(currentIndex) * (cardWidth + cardSpacing)
        return initialOffset + contentOffset + dragOffset
    }
}

#Preview {
    SnapCarousel(items: [
        ("Wake Up", "5 MINUTES"),
        ("Sleep", "10 MINUTES"),
        ("Full Body", "15 MINUTES")
    ]) { title, duration, isSelected in
        RoutineCarouselCard(
            title: title,
            duration: duration,
            isSelected: isSelected
        )
    }
    .frame(height: 300)
} 