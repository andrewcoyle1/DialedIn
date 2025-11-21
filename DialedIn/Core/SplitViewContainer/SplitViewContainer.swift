//
//  SplitViewContainer.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct SplitViewContainer: View {

    @State var viewModel: SplitViewContainerViewModel
    var tabs: [TabBarScreen]

    @ViewBuilder var tabViewAccessoryView: (TabViewAccessoryViewDelegate) -> AnyView
    @ViewBuilder var workoutTrackerView: (WorkoutTrackerViewDelegate) -> AnyView

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), preferredCompactColumn: $viewModel.preferredColumn) {
            // Sidebar
            List {
                Section {
                    ForEach(tabs) { tab in
                        Button {
                            print("Tab selected")
                        } label: {
                            Label(tab.title, systemImage: tab.systemImage)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let active = viewModel.activeSession, !viewModel.isTrackerPresented {
                    tabViewAccessoryView(TabViewAccessoryViewDelegate(active: active))
                        .padding()
                        .buttonStyle(.bordered)
                }
            }
            .frame(minWidth: 150)
        } content: {
            tabs.first!.screen()
//            NavigationStack {
//                tabRootView(delegate.tab.wrappedValue, delegate.path)
//            }
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
        } detail: {
            NavigationStack {
                detailPlaceholder
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: Binding(get: {
            viewModel.isTrackerPresented
        }, set: { newValue in
            viewModel.isTrackerPresented = newValue
        })) {
            if let session = viewModel.activeSession {
                workoutTrackerView(WorkoutTrackerViewDelegate(workoutSession: session))
            }
        }
        .task {
            // Load any active session from local storage when the SplitView appears
            if let active = try? viewModel.getActiveLocalWorkoutSession() {
                viewModel.activeSession = active
            }
        }
//        .onChange(of: tab) { _, _ in
//            path.clear()
//        }
    }
}

#Preview {
    @Previewable @State var path: [TabBarPathOption] = []
    @Previewable @State var tab: TabBarOption = .dashboard
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.splitViewContainer()
    .previewEnvironment()
}

private extension SplitViewContainer {
    var detailPlaceholder: some View {
        Text("Select an item to view details")
            .foregroundStyle(.secondary)
            .padding()
    }
}
