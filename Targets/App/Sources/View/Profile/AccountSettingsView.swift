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
                HStack(spacing: 16) {
                    // Profile Image
                    Button {
                        showingImagePicker = true
                    } label: {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color.brandPrimary)
                        }
                    }
                    
                    // Name and Email Fields
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Name", text: $name)
                            .textContentType(.name)
                            .font(.headline)
                        
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Account Management Section
            Section {
                NavigationLink("Change Password") {
                    Text("Change Password View")
                }
                
                NavigationLink("Privacy Settings") {
                    Text("Privacy Settings View")
                }
                
                NavigationLink("Data & Storage") {
                    Text("Data & Storage View")
                }
            } header: {
                Text("ACCOUNT MANAGEMENT")
            }
            
            // Subscription Section
            Section {
                NavigationLink {
                    Text("Subscription Details View")
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Plan")
                            .font(.headline)
                        Text("Free Plan")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                NavigationLink("Billing History") {
                    Text("Billing History View")
                }
            } header: {
                Text("SUBSCRIPTION")
            }
            
            // Danger Zone Section
            Section {
                Button(role: .destructive) {
                    // Handle logout
                } label: {
                    Text("Log Out")
                }
                
                Button(role: .destructive) {
                    // Handle account deletion
                } label: {
                    Text("Delete Account")
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