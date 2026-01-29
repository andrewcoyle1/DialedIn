//
//  TabBarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI
import SwiftfulRouting

struct TabBarView<TabAccessory: View, Search: View>: View {

    @State var presenter: TabBarPresenter

    var tabs: [TabBarScreen]
    
    @ViewBuilder var tabViewAccessoryView: (TabViewAccessoryDelegate) -> TabAccessory

    @ViewBuilder var searchView: () -> Search
    var body: some View {
        TabView {
            ForEach(tabs) { tab in
                Tab {
                    tab.screen()
                } label: {
                    Label(tab.title, systemImage: tab.systemImage)
                }
            }

            Tab(role: .search) {
                searchView()
            }

        }
        .tabViewStyle(.tabBarOnly)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory(isEnabled: presenter.activeSession != nil) {
            if let active = presenter.activeSession {
                tabViewAccessoryView(TabViewAccessoryDelegate(active: active))
            }
        }
    }
}

extension CoreBuilder {
    
    func tabBarView(router: AnyRouter) -> some View {

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
            )
//            TabBarScreen(
//                title: "Profile",
//                systemImage: "person",
//                screen: {
//                    RouterView { router in
//                        self.profileView(router: router)
//                    }
//                    .any()
//                }
//            )
        ]

        return TabBarView(
            presenter: TabBarPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            tabs: tabs,
            tabViewAccessoryView: { delegate in
                self.tabViewAccessoryView(router: router, delegate: delegate)
            },
            searchView: {
                RouterView { router in
                    self.searchView(router: router)
                }
            }
        )
    }
}

#Preview("Has No Active Session") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.tabBarView(router: router)
    }
    .previewEnvironment()
}

#Preview("Has Active Session") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.tabBarView(router: router)
    }
    .previewEnvironment()
}
