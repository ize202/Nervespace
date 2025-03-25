import SwiftUI

struct SnapCarousel<Content: View>: View {
    let items: [(String, String)]
    @ViewBuilder let content: (String, String, Bool) -> Content
    @State private var currentIndex: Int = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    content(items[index].0, items[index].1, currentIndex == index)
                        .frame(width: geometry.size.width)
                }
            }
            .offset(x: -CGFloat(currentIndex) * geometry.size.width + dragOffset)
            .animation(.interpolatingSpring(stiffness: 100, damping: 12), value: dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.15
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