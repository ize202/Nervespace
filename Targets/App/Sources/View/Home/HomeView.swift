import SwiftUI
import SharedKit

struct HomeView: View {
    @State private var currentIndex: Int = 0
    
    // Common Routines for Carousel
    private let commonRoutines: [RoutineCard] = [
        .init(title: "Wake Up", duration: "5 MINUTES"),
        .init(title: "Sleep", duration: "10 MINUTES"),
        .init(title: "Full Body", duration: "15 MINUTES"),
        .init(title: "Complete Reset", duration: "20 MINUTES")
    ]
    
    // Quick Sessions (under 5 minutes)
    private let quickSessions: [RoutineCard] = [
        .init(title: "Desk Stretch", duration: "5 MINUTES"),
        .init(title: "Neck Relief", duration: "3 MINUTES"),
        .init(title: "Tech Neck", duration: "5 MINUTES"),
        .init(title: "Detox", duration: "4 MINUTES")
    ]
    
    // Multi-day Plans
    private let plans: [RoutineCard] = [
        .init(title: "Morning Routine", duration: "7 DAYS"),
        .init(title: "Stress Relief", duration: "5 DAYS"),
        .init(title: "Better Sleep", duration: "3 DAYS")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                // Header
                header
                
                // Common Routines Carousel
                SnapCarousel(spacing: 15,
                           trailingSpace: 100,
                           index: $currentIndex,
                           items: commonRoutines) { routine in
                    // Carousel Card Style
                    ZStack(alignment: .topLeading) {
                        Image(systemName: routine.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .foregroundStyle(Color.brandPrimary.opacity(0.2))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        VStack(alignment: .leading) {
                            Text(routine.title)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(Color.baseBlack)
                            
                            Spacer()
                            
                            Text(routine.duration.replacingOccurrences(of: "MINUTES", with: "mins"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.8))
                                )
                        }
                        .padding(20)
                    }
                    .background(Color.baseGray)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .frame(height: 320)
                
                VStack(alignment: .leading, spacing: 32) {
                    // Quick Sessions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Sessions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(quickSessions) { session in
                                    // Quick Session Card Style
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(session.title)
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                        Text(session.duration.replacingOccurrences(of: "MINUTES", with: "mins"))
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.8))
                                    }
                                    .frame(width: 160, height: 100)
                                    .padding(16)
                                    .background(Color.brandSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Plans Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Plans")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(plans) { plan in
                                    // Plan Card Style
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(plan.title)
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                        Text(plan.duration)
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.8))
                                    }
                                    .frame(width: 160, height: 100)
                                    .padding(16)
                                    .background(Color(hex: "503370"))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemBackground))
    }
    
    private var header: some View {
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
        .padding(.top)
    }
}

#Preview {
    HomeView()
} 