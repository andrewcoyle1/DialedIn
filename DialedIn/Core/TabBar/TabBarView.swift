//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI

struct TabBarView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @Environment(AppNavigationModel.self) private var appNavigation
    @State private var presentTracker: Bool = false
    
    var body: some View {
        @Bindable var appNavigation = appNavigation
        TabView(selection: $appNavigation.selectedSection) {
            DashboardView()
                .tag(AppSection.dashboard)
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            
            TrainingView()
                .tag(AppSection.training)
                .tabItem {
                    Label("Training", systemImage: "dumbbell")
                }
            
            NutritionView()
                .tag(AppSection.nutrition)
                .tabItem {
                    Label("Nutrition", systemImage: "carrot")
                }
            
            ProfileView(viewModel: ProfileViewModel(container: container))
                .tag(AppSection.profile)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            if let active = workoutSessionManager.activeSession, !workoutSessionManager.isTrackerPresented {
                TabViewAccessory(active: active)
            }
        }
        .fullScreenCover(isPresented: Binding(get: {
            workoutSessionManager.isTrackerPresented
        }, set: { newValue in
            workoutSessionManager.isTrackerPresented = newValue
        })) {
            if let session = workoutSessionManager.activeSession {
                WorkoutTrackerView(viewModel: WorkoutTrackerViewModel(container: container, workoutSession: session), initialWorkoutSession: session)
            }
        }
        .task {
            // Load any active session from local storage when the TabBar appears
            if let active = try? workoutSessionManager.getActiveLocalWorkoutSession() {
                workoutSessionManager.activeSession = active
            }
        }
    }
}

#Preview("Has No Active Session") {
    TabBarView()
        .environment(WorkoutSessionManager(services: MockWorkoutSessionServices(hasActiveSession: false)))
        .previewEnvironment()
}

#Preview("Has Active Session") {
    TabBarView()
        .environment(WorkoutSessionManager(services: MockWorkoutSessionServices(hasActiveSession: true)))
        .previewEnvironment()
}
