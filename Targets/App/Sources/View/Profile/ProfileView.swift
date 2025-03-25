import SwiftUI
import SharedKit

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.baseBlack.ignoresSafeArea()
                
                VStack {
                    Text("Profile")
                        .font(.largeTitle)
                        .foregroundColor(.brandPrimary)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
} 