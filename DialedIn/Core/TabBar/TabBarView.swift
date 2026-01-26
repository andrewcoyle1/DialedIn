//
//  TabBarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI
import SwiftfulRouting

struct TabBarView<TabAccessory: View>: View {

    @State var presenter: TabBarPresenter

    var tabs: [TabBarScreen]
    
    @ViewBuilder var tabViewAccessoryView: (AnyRouter, TabViewAccessoryDelegate) -> TabAccessory

    var body: some View {
        RouterView(addNavigationStack: false) { router in
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
            .tabViewBottomAccessory {
                if let active = presenter.activeSession {
                    tabViewAccessoryView(router, TabViewAccessoryDelegate(active: active))
                }
            }
        }
    }
}

extension CoreBuilder {
    
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
            tabViewAccessoryView: { router, delegate in
                self.tabViewAccessoryView(router: router, delegate: delegate)
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
