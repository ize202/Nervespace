import SwiftUI

struct SnapCarousel<T: Identifiable>: View {
    var list: [T]
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    init(spacing: CGFloat = 15,
         trailingSpace: CGFloat = 100,
         index: Binding<Int>,
         items: [T]) {
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
    }
    
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let cardWidth = size.width - (trailingSpace - spacing)
            let adjustedSpacing = (trailingSpace / 2) - spacing
            
            HStack(spacing: spacing) {
                ForEach(list) { item in
                    let index = getIndex(item: item)
                    // Card Design
                    ZStack(alignment: .topLeading) {
                        if let card = item as? RoutineCard {
                            // Background Image
                            Image(systemName: card.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .foregroundStyle(Color.brandPrimary.opacity(0.2))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                            // Content Overlay
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
                    }
                    .frame(width: proxy.size.width - trailingSpace)
                    .offset(y: getOffset(item: item, cardWidth: cardWidth))
                    .background(Color.baseGray)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(.horizontal, adjustedSpacing)
            .offset(x: (CGFloat(currentIndex) * -cardWidth) + (currentIndex != 0 ? adjustedSpacing : 0) + offset)
            .gesture(
                DragGesture()
                    .updating($offset) { value, out, _ in
                        out = value.translation.width
                    }
                    .onEnded { value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / cardWidth
                        let roundIndex = progress.rounded()
                        currentIndex = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                        currentIndex = index
                    }
                    .onChanged { value in
                        let offsetX = value.translation.width
                        let progress = -offsetX / cardWidth
                        let roundIndex = progress.rounded()
                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                    }
            )
        }
        .animation(.easeInOut, value: offset == 0)
    }
    
    private func getOffset(item: T, cardWidth: CGFloat) -> CGFloat {
        let index = getIndex(item: item)
        let topOffset = -cardWidth * 0.1
        return index == currentIndex ? 0 : topOffset
    }
    
    private func getIndex(item: T) -> Int {
        let index = list.firstIndex { current in
            current.id == item.id
        } ?? 0
        return index
    }
}

#Preview {
    SnapCarousel(index: .constant(0), items: RoutineCard.sampleCards)
        .frame(height: 400)
} 