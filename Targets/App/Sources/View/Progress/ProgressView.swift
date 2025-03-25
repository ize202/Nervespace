import SwiftUI
import SharedKit

struct ProgressView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Progress")
                    .font(.largeTitle)
                    .foregroundColor(.brandPrimary)
            }
            .navigationTitle("Progress")
        }
    }
}

#Preview {
    ProgressView()
} 