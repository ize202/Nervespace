import SwiftUI
import SharedKit

struct HomeView: View {
    // For MVP, we'll use static data
    private let mostUsedRoutines = [
        ("Wake Up", "5 MINUTES"),
        ("Sleep", "10 MINUTES"),
        ("Full Body", "15 MINUTES"),
        ("Complete Reset", "20 MINUTES")
    ]
    
    private let quickSessions = [
        ("Desk Stretch", "5 MINUTES"),
        ("Neck Relief", "3 MINUTES"),
        ("Tech Neck", "5 MINUTES"),
        ("Detox", "10 MINUTES")
    ]
    
    private let plans = [
        ("Morning Routine", "7 DAYS"),
        ("Stress Relief", "5 DAYS"),
        ("Better Sleep", "3 DAYS")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("Nervespace")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("4")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.1))
                    )
                }
                .padding(.horizontal)
                
                // Most Used Routines Carousel
                SnapCarousel(items: mostUsedRoutines) { title, duration, isSelected in
                    RoutineCarouselCard(
                        title: title,
                        duration: duration,
                        isSelected: isSelected
                    )
                }
                .frame(height: 280)
                
                VStack(alignment: .leading, spacing: 24) {
                    // Quick Sessions
                    Text("Quick Sessions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(quickSessions, id: \.0) { session in
                                SessionCard(
                                    title: session.0,
                                    duration: session.1,
                                    backgroundColor: .brandSecondary
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Plans
                    Text("Plans")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(plans, id: \.0) { plan in
                                SessionCard(
                                    title: plan.0,
                                    duration: plan.1,
                                    backgroundColor: Color(hex: "503370")
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    HomeView()
} 