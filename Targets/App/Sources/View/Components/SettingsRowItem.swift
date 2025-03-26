import SwiftUI

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