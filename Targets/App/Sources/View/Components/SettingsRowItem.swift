import SwiftUI

struct SettingsRowItem: View {
    let label: String
    let isDestructive: Bool
    
    init(label: String, isDestructive: Bool = false) {
        self.label = label
        self.isDestructive = isDestructive
    }
    
    var body: some View {
        Text(label)
            .foregroundColor(isDestructive ? .red : .primary)
    }
} 