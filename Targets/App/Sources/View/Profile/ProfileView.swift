import SwiftUI
import SharedKit

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile")
                    .font(.largeTitle)
                    .foregroundColor(.brandPrimary)
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
} 