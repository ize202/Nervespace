import SwiftUI
import SharedKit


struct AccountSettingsView: View {
    @State private var name = "Aize Igbinakenzua"
    @State private var email = "aizeakenzua@gmail.com"
    @State private var showingImagePicker = false
    @State private var profileImage: UIImage?
    
    var body: some View {
        List {
            // Profile Section
            Section {
                VStack(spacing: 16) {
                    // Profile Image
                    Button {
                        showingImagePicker = true
                    } label: {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .background(
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 102, height: 102)
                                )
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.brandPrimary)
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    
                    // Name and Email
                    VStack(spacing: 4) {
                        Text(name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }
            .listRowInsets(EdgeInsets())
            
            // Account Management Section
            Section {
                NavigationLink {
                    Text("Change Password View")
                } label: {
                    SettingsRowItem(label: "Change Password")
                }
                
                NavigationLink {
                    Text("Privacy Settings View")
                } label: {
                    SettingsRowItem(label: "Privacy Settings")
                }
                
                NavigationLink {
                    Text("Data & Storage View")
                } label: {
                    SettingsRowItem(label: "Data & Storage")
                }
            } header: {
                Text("ACCOUNT MANAGEMENT")
            }
            
            // Subscription Section
            Section {
                NavigationLink {
                    Text("Subscription Details View")
                } label: {
                    SettingsRowItem(label: "Current Plan")
                }
                
                NavigationLink {
                    Text("Billing History View")
                } label: {
                    SettingsRowItem(label: "Billing History")
                }
            } header: {
                Text("SUBSCRIPTION")
            }
            
            // Danger Zone Section
            Section {
                Button(role: .destructive) {
                    // Handle logout
                } label: {
                    SettingsRowItem(label: "Log Out", isDestructive: true)
                }
                
                Button(role: .destructive) {
                    // Handle account deletion
                } label: {
                    SettingsRowItem(label: "Delete Account", isDestructive: true)
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
}

// Image Picker struct to handle profile photo selection
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    NavigationView {
        AccountSettingsView()
    }
} 
