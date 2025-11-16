//
//  TabBarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI

struct TabBarViewDelegate {

    var path: Binding<[TabBarPathOption]>
    var tab: Binding<TabBarOption>
}

struct TabBarView: View {
    
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: TabBarViewModel

    var delegate: TabBarViewDelegate

    var body: some View {
        TabView(selection: delegate.tab) {
            ForEach(TabBarOption.allCases) { tab in
                Tab(tab.name, systemImage: tab.symbolName, value: tab) {
                    NavigationStack(path: delegate.path) {
                        tab.viewForPage(builder: builder, path: delegate.path)
                    }
                    .navDestinationForTabBarModule(path: delegate.path)
                }
            }
        }
        .tabViewStyle(.tabBarOnly)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            if let active = viewModel.active, !viewModel.trackerPresented {
                let delegate = TabViewAccessoryViewDelegate(active: active)
                builder.tabViewAccessoryView(delegate: delegate)
            }
        }
        .fullScreenCover(isPresented: Binding(get: {
            viewModel.isTrackerPresented
        }, set: { newValue in
            viewModel.isTrackerPresented = newValue
        })) {
            if let session = viewModel.activeSession {
                builder.workoutTrackerView(delegate: WorkoutTrackerViewDelegate(workoutSession: session))
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
    let delegate = TabBarViewDelegate(path: $path, tab: $tab)
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.tabBarView(delegate: delegate)
    .previewEnvironment()
}

#Preview("Has Active Session") {
    @Previewable @State var path: [TabBarPathOption] = []
    @Previewable @State var tab: TabBarOption = .dashboard
    let delegate = TabBarViewDelegate(path: $path, tab: $tab)
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.tabBarView(delegate: delegate)
    .previewEnvironment()
}
