import SwiftUI

struct SnapCarousel<Content: View>: View {
    let items: [(String, String)]
    @ViewBuilder let content: (String, String, Bool) -> Content
    @State private var currentIndex: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(items.indices, id: \.self) { index in
                        GeometryReader { proxy in
                            let isCurrent = currentIndex == index
                            
                            content(items[index].0, items[index].1, isCurrent)
                                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 5)
                                .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                                    view
                                        .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                        .opacity(phase.isIdentity ? 1 : 0.5)
                                }
                        }
                        .frame(width: size.width - 80) // Card width with padding
                    }
                }
                .padding(.horizontal, 40)
                .scrollTargetLayout()
                .frame(height: size.height, alignment: .top)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
            .scrollPosition(id: .init(get: {
                currentIndex
            }, set: { newIndex in
                if let newIndex {
                    currentIndex = newIndex
                }
            }))
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