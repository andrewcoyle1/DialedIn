//
//  TabBarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI
import SwiftfulRouting

struct TabBarView<TabAccessory: View, WorkoutTracker: View>: View {

    @State var presenter: TabBarPresenter

    var tabs: [TabBarScreen]
    
    @ViewBuilder var tabViewAccessoryView: (TabViewAccessoryDelegate) -> TabAccessory
    @ViewBuilder var workoutTrackerView: (WorkoutTrackerDelegate) -> WorkoutTracker

    var body: some View {
        TabView {
            ForEach(tabs) { tab in
                tab.screen()
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
            }
        }
        .tabViewStyle(.tabBarOnly)
        .tabBarMinimizeBehavior(.onScrollDown)
        .workoutTabAccessory(
            active: presenter.activeSession,
            tabViewAccessoryView: tabViewAccessoryView
        )
//        .tabViewBottomAccessory {
//            if let active = presenter.activeSession {
//                tabViewAccessoryView(TabViewAccessoryDelegate(active: active))
//            }
//        }
        .fullScreenCover(
            isPresented: Binding(
                get: { presenter.isTrackerPresented },
                set: { presenter.isTrackerPresented = $0 }
            )
        ) {
            if let active = presenter.activeSession {
                let delegate = WorkoutTrackerDelegate(workoutSession: active)
                workoutTrackerView(delegate)
                    .onAppear {
                        print("🪟 TabBarView fullScreenCover presented for session id=\(active.id)")
                    }
            }
        }
        .task {
            presenter.checkForActiveSession()
        }
    }
}

extension CoreBuilder {
    
    // swiftlint:disable:next function_body_length
    func tabBarView() -> some View {
        
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
        
        return TabBarView(
            presenter: TabBarPresenter(interactor: interactor),
            tabs: tabs,
            tabViewAccessoryView: { delegate in
                self.tabViewAccessoryView(delegate: delegate)
            },
            workoutTrackerView: { delegate in
                RouterView { router in
                    self.workoutTrackerView(router: router, delegate: delegate)
                }
            }
        )
    }
}

#Preview("Has No Active Session") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.tabBarView()
        .previewEnvironment()
}

#Preview("Has Active Session") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.tabBarView()
        .previewEnvironment()
}
