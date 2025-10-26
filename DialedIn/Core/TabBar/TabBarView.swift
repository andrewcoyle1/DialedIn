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
            Tab("Dashboard", systemImage: "house", value: AppSection.dashboard) {
                DashboardView(viewModel: DashboardViewModel(interactor: CoreInteractor(container: container)))
            }
            
            Tab("Training", systemImage: "dumbbell", value: AppSection.training) {
                TrainingView(viewModel: TrainingViewModel(interactor: CoreInteractor(container: container)))
            }
            
            Tab("Nutrition", systemImage: "carrot", value: AppSection.nutrition) {
                NutritionView(viewModel: NutritionViewModel(interactor: CoreInteractor(container: container)))
            }
            
            Tab("Profile", systemImage: "person.fill", value: AppSection.profile) {
                ProfileView(viewModel: ProfileViewModel(interactor: CoreInteractor(container: container)))
            }
            
            Tab(value: AppSection.search, role: .search) {
                SearchView()
            }
        }
        .tabViewStyle(.tabBarOnly)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            if let active = viewModel.active, !viewModel.trackerPresented {
                TabViewAccessoryView(viewModel: TabViewAccessoryViewModel(interactor: CoreInteractor(container: container)), active: active)
            }
        }
        .fullScreenCover(isPresented: Binding(get: {
            workoutSessionManager.isTrackerPresented
        }, set: { newValue in
            workoutSessionManager.isTrackerPresented = newValue
        })) {
            if let session = workoutSessionManager.activeSession {
                WorkoutTrackerView(viewModel: WorkoutTrackerViewModel(interactor: CoreInteractor(container: container), workoutSession: session), initialWorkoutSession: session)
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
