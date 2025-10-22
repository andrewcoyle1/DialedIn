//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI

struct TabBarView: View {
    
    @State var viewModel: TabBarViewModel
    @Environment(DependencyContainer.self) private var container
    @Environment(WorkoutSessionManager.self) private var workoutSessionManager
    @Environment(AppNavigationModel.self) private var appNavigation
    
    var body: some View {
        @Bindable var appNavigation = appNavigation
        TabView(selection: $appNavigation.selectedSection) {
            DashboardView()
                .tag(AppSection.dashboard)
                .tabItem {
                    Label("Dashboard", systemImage: "house")
                }
            
            TrainingView(viewModel: TrainingViewModel(container: container))
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
            if let active = viewModel.active, !viewModel.trackerPresented {
                TabViewAccessoryView(viewModel: TabViewAccessoryViewModel(container: container), active: active)
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
            _ = viewModel.checkForActiveSession()
        }
    }
}

#Preview("Has No Active Session") {
    TabBarView(viewModel: TabBarViewModel(container: DevPreview.shared.container))
        .environment(WorkoutSessionManager(services: MockWorkoutSessionServices(hasActiveSession: false)))
        .previewEnvironment()
}

#Preview("Has Active Session") {
    TabBarView(viewModel: TabBarViewModel(container: DevPreview.shared.container))
        .environment(WorkoutSessionManager(services: MockWorkoutSessionServices(hasActiveSession: true)))
        .previewEnvironment()
}
