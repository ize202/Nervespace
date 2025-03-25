import SwiftUI
import SharedKit

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Home")
                    .font(.largeTitle)
                    .foregroundColor(.brandPrimary)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
} 