import SwiftUI

struct SnapCarousel<Content: View, T: Identifiable>: View {
    var content: (T) -> Content
    var list: [T]
    var spacing: CGFloat
    var cardWidth: CGFloat?
    @Binding var index: Int
    
    init(spacing: CGFloat = 15,
         cardWidth: CGFloat? = nil,
         index: Binding<Int>,
         items: [T],
         @ViewBuilder content: @escaping (T) -> Content) {
        self.list = items
        self.spacing = spacing
        self.cardWidth = cardWidth
        self._index = index
        self.content = content
    }
    
    @State private var scrollPosition: T.ID?
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let computedCardWidth = cardWidth ?? (size.width - 60)
            
            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    ForEach(list) { item in
                        content(item)
                            .frame(width: computedCardWidth)
                            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.95)
                            }
                            .id(item.id)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, (size.width - computedCardWidth) / 2)
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrollPosition)
            .onChange(of: scrollPosition) { oldValue, newValue in
                if let newPosition = newValue,
                   let newIndex = list.firstIndex(where: { $0.id == newPosition }) {
                    index = newIndex
                }
            }
            .onChange(of: index) { oldValue, newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    scrollPosition = list[newValue].id
                }
            }
        }
    }
}

#Preview {
    SnapCarousel(index: .constant(0), items: RoutineCard.sampleCards) { card in
        // Example card styling
        ZStack(alignment: .topLeading) {
            Image(systemName: card.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundStyle(Color.brandPrimary.opacity(0.2))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(alignment: .leading) {
                Text(card.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.baseBlack)
                
                Spacer()
                
                Text(card.duration.replacingOccurrences(of: "MINUTES", with: "mins"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.8))
                    )
            }
            .padding(20)
        }
        .background(Color.baseGray)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    .frame(height: 400)
} 