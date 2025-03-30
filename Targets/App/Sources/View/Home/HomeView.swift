import SwiftUI
import SharedKit

struct HomeView: View {
    @State private var currentIndex: Int = 0
    @State private var showingProfile = false
    @StateObject private var bookmarkManager = BookmarkManager.shared
    
    // Common Routines for Carousel (first 3 routines)
    private var commonRoutines: [Routine] {
        Array(RoutineLibrary.routines.prefix(3))
    }
    
    // Quick Sessions (under 5 minutes)
    private var quickSessions: [Routine] {
        RoutineLibrary.quickRoutines
    }
    
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
                            NavigationLink(destination: RoutineDetailView(routine: routine)) {
                                // Carousel Card Style
                                ZStack(alignment: .topLeading) {
                                    Color.brandPrimary.opacity(0.2)
                                    
                                    VStack(alignment: .leading) {
                                        Text(routine.name)
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundStyle(Color.baseWhite)
                                        
                                        Spacer()
                                        
                                        Text("\(routine.exercises.count) exercises • \(routine.totalDuration / 60) min")
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
                                            NavigationLink(destination: RoutineDetailView(routine: routine)) {
                                                // Quick Session Card Style
                                                VStack(alignment: .leading, spacing: 12) {
                                                    // Image container
                                                    Image(routine.thumbnailName)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 200, height: 160)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                    
                                                    // Text content
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(routine.name)
                                                            .font(.headline)
                                                            .foregroundStyle(Color.baseWhite)
                                                        
                                                        Text("\(routine.exercises.count) exercises • \(routine.totalDuration / 60) min")
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
                                        ForEach(PlanLibrary.plans) { plan in
                                            NavigationLink(destination: PlanDetailView(plan: plan)) {
                                                // Plan Card Style
                                                VStack(alignment: .leading, spacing: 12) {
                                                    // Image container
                                                    Image(plan.thumbnailName)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 200, height: 160)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                    
                                                    // Text content
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(plan.name)
                                                            .font(.headline)
                                                            .foregroundStyle(Color.baseWhite)
                                                        
                                                        Text("\(plan.routines.count) routines")
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

