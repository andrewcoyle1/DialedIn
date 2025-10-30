//
//  TabBarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: TabBarViewModel
    
    var body: some View {
        @Bindable var appNavigation = viewModel.appNavigation
        TabView(selection: $appNavigation.selectedSection) {
            Tab("Dashboard", systemImage: "house", value: AppSection.dashboard) {
                DashboardView(
                    viewModel: DashboardViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            
            Tab("Training", systemImage: "dumbbell", value: AppSection.training) {
                TrainingView(
                    viewModel: TrainingViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            
            Tab("Nutrition", systemImage: "carrot", value: AppSection.nutrition) {
                NutritionView(
                    viewModel: NutritionViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            
            Tab("Profile", systemImage: "person.fill", value: AppSection.profile) {
                ProfileView(
                    viewModel: ProfileViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            
            Tab(value: AppSection.search, role: .search) {
                SearchView()
            }
        }
        .tabViewStyle(.tabBarOnly)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            if let active = viewModel.active, !viewModel.trackerPresented {
                TabViewAccessoryView(
                    viewModel: TabViewAccessoryViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    ),
                    active: active
                )
            }
        }
        .fullScreenCover(isPresented: Binding(get: {
            viewModel.isTrackerPresented
        }, set: { newValue in
            viewModel.isTrackerPresented = newValue
        })) {
            if let session = viewModel.activeSession {
                WorkoutTrackerView(viewModel: WorkoutTrackerViewModel(interactor: CoreInteractor(container: container), workoutSession: session), initialWorkoutSession: session)
            }
        }
        .task {
            _ = viewModel.checkForActiveSession()
        }
    }
}

#Preview("Has No Active Session") {
    TabBarView(
        viewModel: TabBarViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            appNavigation: AppNavigationModel()
        )
    )
        .previewEnvironment()
}

#Preview("Has Active Session") {
    TabBarView(
        viewModel: TabBarViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            ),
            appNavigation: AppNavigationModel()
        )
    )
        .previewEnvironment()
}
