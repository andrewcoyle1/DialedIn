//
//  TabBarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI

struct TabBarView: View {
    
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: TabBarViewModel

    @Binding var path: [TabBarPathOption]
    @Binding var tab: TabBarOption
    
    var body: some View {
        TabView(selection: $tab) {
            ForEach(TabBarOption.allCases) { tab in
                Tab(tab.name, systemImage: tab.symbolName, value: tab) {
                    NavigationStack(path: $path) {
                        tab.viewForPage(builder: builder, path: $path)
                    }
                    .navDestinationForTabBarModule(path: $path)
                }
            }
        }
        .tabViewStyle(.tabBarOnly)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            if let active = viewModel.active, !viewModel.trackerPresented {
                builder.tabViewAccessoryView(active: active)
            }
        }
        .fullScreenCover(isPresented: Binding(get: {
            viewModel.isTrackerPresented
        }, set: { newValue in
            viewModel.isTrackerPresented = newValue
        })) {
            if let session = viewModel.activeSession {
                builder.workoutTrackerView(workoutSession: session, initialWorkoutSession: session)
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.tabBarView(path: $path, tab: $tab)
    .previewEnvironment()
}

#Preview("Has Active Session") {
    @Previewable @State var path: [TabBarPathOption] = []
    @Previewable @State var tab: TabBarOption = .dashboard
    
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.tabBarView(path: $path, tab: $tab)
    .previewEnvironment()
}
