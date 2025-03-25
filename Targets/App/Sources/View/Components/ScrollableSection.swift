import SwiftUI

struct ScrollableSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    content
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    ScrollableSection(title: "Quick Sessions") {
        ForEach(0..<5) { _ in
            SessionCard(
                title: "Wake Up",
                duration: "5 MINUTES",
                backgroundColor: .brandPrimary
            )
        }
    }
} 