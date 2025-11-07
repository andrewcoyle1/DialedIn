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

    @Binding var path: [TabBarPathOption]
    @Binding var tab: TabBarOption
    
    var body: some View {
        TabView(selection: $tab) {
            ForEach(TabBarOption.allCases) { tab in
                Tab(tab.name, systemImage: tab.symbolName, value: tab) {
                    NavigationStack(path: $path) {
                        tab.viewForPage(container: container, path: $path)
                    }
                    .navDestinationForTabBarModule(path: $path)
                }
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
    @Previewable @State var path: [TabBarPathOption] = []
    @Previewable @State var tab: TabBarOption = .dashboard

    TabBarView(
        viewModel: TabBarViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        ),
        path: $path,
        tab: $tab
    )
    .previewEnvironment()
}

#Preview("Has Active Session") {
    @Previewable @State var path: [TabBarPathOption] = []
    @Previewable @State var tab: TabBarOption = .dashboard

    TabBarView(
        viewModel: TabBarViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        ),
        path: $path,
        tab: $tab
    )
    .previewEnvironment()
}
