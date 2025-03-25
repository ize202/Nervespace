import SwiftUI
import SharedKit

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Areas, Exercises, Categories, and More", text: $text)
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
        VStack(spacing: 0) {
            // Icon container
            ZStack {
                Color.white
                Image(systemName: systemImage)
                    .font(.system(size: 40))
                    .foregroundColor(.brandPrimary)
            }
            .frame(height: 120)
            
            // Title container
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.baseBlack)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Color.white)
        }
        .frame(width: 160)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

struct AreaCard: View {
    let title: String
    let color: Color
    let imageUrl: String?
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background with gradient overlay
            ZStack {
                if let imageUrl = imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        color
                    }
                } else {
                    color
                }
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.5),
                        .clear,
                        .clear
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            }
            
            // Title
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(16)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ExploreView: View {
    @State private var searchText = ""
    
    // Grid layout configuration
    private let gridItems = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    header
                    
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    // Browse by Category
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Browse by Category")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                CategoryCard(title: "Meditation", systemImage: "heart.circle.fill")
                                CategoryCard(title: "Breathwork", systemImage: "wind")
                                CategoryCard(title: "Movement", systemImage: "figure.walk")
                                CategoryCard(title: "Grounding", systemImage: "leaf.fill")
                                CategoryCard(title: "Sleep", systemImage: "moon.stars.fill")
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Browse by Area
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Browse by Area")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: gridItems, spacing: 16) {
                            AreaCard(
                                title: "Stress Relief",
                                color: .brandPrimary,
                                imageUrl: nil
                            )
                            AreaCard(
                                title: "Anxiety",
                                color: .brandSecondary,
                                imageUrl: nil
                            )
                            AreaCard(
                                title: "Focus & Clarity",
                                color: Color(hex: "6B8E23"),
                                imageUrl: nil
                            )
                            AreaCard(
                                title: "Energy Boost",
                                color: Color(hex: "CD853F"),
                                imageUrl: nil
                            )
                            AreaCard(
                                title: "Better Sleep",
                                color: .brandPrimary,
                                imageUrl: nil
                            )
                            AreaCard(
                                title: "Quick Reset",
                                color: .brandSecondary,
                                imageUrl: nil
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.baseBlack)
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
    
    private var header: some View {
        HStack {
            Text("Explore")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bookmark")
                    .foregroundColor(.brandPrimary)
                    .font(.system(size: 24))
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

#Preview {
    ExploreView()
        .preferredColorScheme(.dark)
        .background(Color.baseBlack)
} 
