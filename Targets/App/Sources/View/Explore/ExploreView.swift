import SwiftUI
import SharedKit

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search sessions...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color.baseGray)
        .cornerRadius(10)
    }
}

struct CategoryCard: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .font(.system(size: 30))
                .foregroundColor(.brandPrimary)
                .frame(width: 60, height: 60)
                .background(Color.baseGray)
                .cornerRadius(12)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.baseBlack)
        }
        .frame(width: 80)
    }
}

struct AreaCard: View {
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
        }
        .frame(width: 160, height: 100)
        .background(color)
        .cornerRadius(12)
    }
}

struct ExploreView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    // Browse by Category
                    VStack(alignment: .leading) {
                        Text("Browse by Category")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                CategoryCard(title: "Breathwork", systemImage: "wind")
                                CategoryCard(title: "Movement", systemImage: "figure.walk")
                                CategoryCard(title: "Grounding", systemImage: "leaf")
                                CategoryCard(title: "Sleep", systemImage: "moon.stars")
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Browse by Area
                    VStack(alignment: .leading) {
                        Text("Browse by Area")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                AreaCard(title: "Stress Relief", color: .brandPrimary)
                                AreaCard(title: "Anxiety", color: .brandSecondary)
                                AreaCard(title: "Focus", color: Color(hex: "6B8E23"))
                                AreaCard(title: "Energy", color: Color(hex: "CD853F"))
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Explore")
            .navigationBarItems(trailing: Button(action: {}) {
                Image(systemName: "bookmark")
                    .foregroundColor(.brandPrimary)
            })
        }
    }
}

#Preview {
    ExploreView()
} 