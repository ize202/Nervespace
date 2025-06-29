import SwiftUI
import SupabaseKit
import SharedKit

// MARK: - Header View
private struct HomeHeaderView: View {
    @Binding var showingProfile: Bool
    let streak: Int
    
    var body: some View {
        HStack {
            Text("Form")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.baseWhite)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("\(streak)")
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
    }
}

// MARK: - Quick Sessions View
private struct QuickSessionsView: View {
    let quickSessions: [Routine]
    
    var body: some View {
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
                            QuickSessionCard(routine: routine)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Quick Session Card
private struct QuickSessionCard: View {
    let routine: Routine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(routine.thumbnailName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
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

// MARK: - Plans View
private struct PlansView: View {
    let plans: [Plan]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Plans")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.baseWhite)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(plans) { plan in
                        NavigationLink(destination: PlanDetailView(
                            title: plan.name,
                            description: plan.description,
                            duration: "\(plan.routines.count) DAY SERIES",
                            routines: plan.routines.map(\.routine)
                        )) {
                            PlanCard(plan: plan)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Plan Card
private struct PlanCard: View {
    let plan: Plan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(plan.thumbnailName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 280, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
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
        .frame(width: 280)
    }
}

// MARK: - Main View
struct HomeView: View {
    @State private var currentIndex: Int = 0
    @State private var showingProfile = false
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @EnvironmentObject private var progressStore: LocalProgressStore
    @EnvironmentObject private var syncManager: SupabaseSyncManager
    
    // Common Routines for Carousel (core routines)
    private var commonRoutines: [Routine] {
        RoutineLibrary.coreRoutines
    }
    
    // Quick Sessions (quick category routines)
    private var quickSessions: [Routine] {
        RoutineLibrary.quickRoutines
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.baseBlack.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 40) {
                        HomeHeaderView(showingProfile: $showingProfile, streak: progressStore.streak)
                        
                        // Common Routines Carousel
                        SnapCarousel(spacing: 9,
                                   index: $currentIndex,
                                   items: commonRoutines) { routine in
                            NavigationLink(destination: RoutineDetailView(routine: routine)) {
                                CarouselCard(routine: routine)
                            }
                        }
                        .frame(height: 320)
                        
                        VStack(alignment: .leading, spacing: 32) {
                            QuickSessionsView(quickSessions: quickSessions)
                            PlansView(plans: PlanLibrary.plans)
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
        .task {
            // Initial sync when view appears
            await syncManager.syncSupabaseToLocal()
        }
    }
}

// MARK: - Carousel Card
private struct CarouselCard: View {
    let routine: Routine
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Image(routine.thumbnailName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // Gradient overlay for text visibility
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.4),
                        .clear,
                        .black.opacity(0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                
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
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
} 

