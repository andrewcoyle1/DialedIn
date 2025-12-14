//
//  SplitViewContainer.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct SplitViewContainer<TabAccessory: View, WorkoutTracker: View>: View {

    @State var presenter: SplitViewContainerPresenter
    var tabs: [TabBarScreen]

    @ViewBuilder var tabViewAccessoryView: (TabViewAccessoryDelegate) -> TabAccessory
    @ViewBuilder var workoutTrackerView: (WorkoutTrackerDelegate) -> WorkoutTracker
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all), preferredCompactColumn: $presenter.preferredColumn) {
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
                if let active = presenter.activeSession, !presenter.isTrackerPresented {
                    tabViewAccessoryView(TabViewAccessoryDelegate(active: active))
                        .padding()
                        .buttonStyle(.bordered)
                }
            }
            .frame(minWidth: 150)
        } content: {
            tabs.first!.screen()
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
        } detail: {
            NavigationStack {
                detailPlaceholder
            }
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { presenter.isTrackerPresented },
                set: { presenter.isTrackerPresented = $0 }
            )
        ) {
            if let active = presenter.activeSession {
                let delegate = WorkoutTrackerDelegate(workoutSession: active)
                workoutTrackerView(delegate)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .task {
            // Load any active session from local storage when the SplitView appears
            if let active = try? presenter.getActiveLocalWorkoutSession() {
                presenter.activeSession = active
            }
        }
    }
}

extension CoreBuilder {
    
    // swiftlint:disable:next function_body_length
    func splitViewContainer() -> some View {
        let tabs: [TabBarScreen] = [
            TabBarScreen(
                title: "Dashboard",
                systemImage: "house",
                screen: {
                    RouterView { router in
                        self.dashboardView(router: router)
                    }
                    .any()
                }
            ),
            TabBarScreen(
                title: "Nutrition",
                systemImage: "carrot",
                screen: {
                    RouterView { router in
                        self.nutritionView(router: router)
                    }
                    .any()
                }
            ),
            TabBarScreen(
                title: "Training",
                systemImage: "dumbbell",
                screen: {
                    RouterView { router in
                        self.trainingView(router: router)
                    }
                    .any()
                }
            ),
            TabBarScreen(
                title: "Profile",
                systemImage: "person",
                screen: {
                    RouterView { router in
                        self.profileView(router: router)
                    }
                    .any()
                }
            )
        ]
        
        return SplitViewContainer(
            presenter: SplitViewContainerPresenter(interactor: interactor),
            tabs: tabs,
            tabViewAccessoryView: { accessoryDelegate in
                self.tabViewAccessoryView( delegate: accessoryDelegate)
            },
            workoutTrackerView: { delegate in
                RouterView { router in
                    self.workoutTrackerView(router: router, delegate: delegate)
                }
            }
        )
    }
}

#Preview {
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
