import SwiftUI
import SharedKit

struct ExploreView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Explore")
                    .font(.largeTitle)
                    .foregroundColor(.brandPrimary)
            }
            .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
} 