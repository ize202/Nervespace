import SwiftUI
import SharedKit

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.baseBlack.ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        Text("Profile Content")
                            .foregroundColor(.brandPrimary)
                    }
                    .padding()
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