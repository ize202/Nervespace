import SwiftUI
import SharedKit

// Settings row styling
struct SettingsRowItem: View {
    let iconName: String
    let label: String
    let iconColor: Color
    
    init(iconName: String, label: String, iconColor: Color) {
        self.iconName = iconName
        self.label = label
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .foregroundStyle(.white)
                .font(.callout)
                .frame(width: 25, height: 25)
                .background(iconColor.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            Text(label)
        }
    }
}

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
                    SettingsRowItem(iconName: "key.fill", 
                                  label: "Change Password", 
                                  iconColor: Color.accentColor)
                }
                
                NavigationLink {
                    Text("Privacy Settings View")
                } label: {
                    SettingsRowItem(iconName: "hand.raised.fill", 
                                  label: "Privacy Settings", 
                                  iconColor: Color.brandPrimary)
                }
                
                NavigationLink {
                    Text("Data & Storage View")
                } label: {
                    SettingsRowItem(iconName: "externaldrive.fill", 
                                  label: "Data & Storage", 
                                  iconColor: Color.brandPrimary.opacity(0.8))
                }
            } header: {
                Text("ACCOUNT MANAGEMENT")
            }
            
            // Subscription Section
            Section {
                NavigationLink {
                    Text("Subscription Details View")
                } label: {
                    SettingsRowItem(iconName: "creditcard.fill", 
                                  label: "Current Plan", 
                                  iconColor: Color.orange)
                }
                
                NavigationLink {
                    Text("Billing History View")
                } label: {
                    SettingsRowItem(iconName: "clock.fill", 
                                  label: "Billing History", 
                                  iconColor: Color.orange)
                }
            } header: {
                Text("SUBSCRIPTION")
            }
            
            // Danger Zone Section
            Section {
                Button(role: .destructive) {
                    // Handle logout
                } label: {
                    SettingsRowItem(iconName: "rectangle.portrait.and.arrow.right", 
                                  label: "Log Out", 
                                  iconColor: Color.red)
                }
                
                Button(role: .destructive) {
                    // Handle account deletion
                } label: {
                    SettingsRowItem(iconName: "trash.fill", 
                                  label: "Delete Account", 
                                  iconColor: Color.red)
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