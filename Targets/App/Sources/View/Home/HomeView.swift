import SwiftUI
import SharedKit
import SupabaseKit

struct HomeView: View {
    @State private var currentIndex: Int = 0
    @State private var showingProfile = false
    @StateObject private var bookmarkManager = BookmarkManager.shared
    
    // Common Routines for Carousel
    private let commonRoutines: [Routine] = [
        .mockWakeAndShake,
        .mockEveningUnwind,
        .mockQuickReset
    ]
    
    // Quick Sessions (under 5 minutes)
    private let quickSessions: [Routine] = [
        .mockWakeAndShake,
        .mockEveningUnwind,
        .mockQuickReset
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.baseBlack.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 40) {
                        // Header with streak
                        HStack {
                            Text("Nervespace")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.baseWhite)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                Text("4")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.baseWhite)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.orange.opacity(0.25))
                            )
                            
                            Button {
                                showingProfile = true
                            } label: {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(Color.brandPrimary)
                            }
                            .padding(.leading, 8)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Common Routines Carousel
                        SnapCarousel(spacing: 9,
                                   index: $currentIndex,
                                   items: commonRoutines) { routine in
                            NavigationLink(destination: RoutineDetailView(
                                routine: routine,
                                exercises: Dictionary.mockRoutineExercises[routine.id] ?? []
                            )) {
                                // Carousel Card Style
                                ZStack(alignment: .topLeading) {
                                    Color.brandPrimary.opacity(0.2)
                                    
                                    VStack(alignment: .leading) {
                                        Text(routine.name)
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundStyle(Color.baseWhite)
                                        
                                        Spacer()
                                        
                                        Text("\(Dictionary.mockRoutineExercises[routine.id]?.count ?? 0) exercises • 5 min")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color.baseWhite)
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
                        }
                        .frame(height: 320)
                        
                        VStack(alignment: .leading, spacing: 32) {
                            // Quick Sessions Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Quick Routines")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.baseWhite)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(quickSessions) { routine in
                                            NavigationLink(destination: RoutineDetailView(
                                                routine: routine,
                                                exercises: Dictionary.mockRoutineExercises[routine.id] ?? []
                                            )) {
                                                // Quick Session Card Style
                                                VStack(alignment: .leading, spacing: 12) {
                                                    // Image container
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.brandPrimary.opacity(0.2))
                                                        .frame(width: 200, height: 160)
                                                    
                                                    // Text content
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(routine.name)
                                                            .font(.headline)
                                                            .foregroundStyle(Color.baseWhite)
                                                        
                                                        Text("\(Dictionary.mockRoutineExercises[routine.id]?.count ?? 0) exercises • 5 min")
                                                            .font(.subheadline)
                                                            .foregroundStyle(Color.baseWhite.opacity(0.6))
                                                    }
                                                    .padding(.horizontal, 4)
                                                }
                                                .frame(width: 200)
                                            }
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
                                    .foregroundStyle(Color.baseWhite)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(spacing: 16) {
                                        ForEach(Plan.allMockPlans) { plan in
                                            NavigationLink(destination: PlanDetailView(
                                                title: plan.name,
                                                description: plan.description,
                                                duration: plan.duration,
                                                routines: plan.routines
                                            )) {
                                                // Plan Card Style
                                                VStack(alignment: .leading, spacing: 12) {
                                                    // Image container
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(Color.brandPrimary.opacity(0.2))
                                                        .frame(width: 320, height: 200)
                                                    
                                                    // Text content
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(plan.name)
                                                            .font(.title3)
                                                            .fontWeight(.bold)
                                                            .foregroundStyle(Color.baseWhite)
                                                        
                                                        Text(plan.duration.lowercased())
                                                            .font(.subheadline)
                                                            .foregroundStyle(Color.baseWhite.opacity(0.6))
                                                    }
                                                    .padding(.horizontal, 4)
                                                }
                                                .frame(width: 320)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView()
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
} 

