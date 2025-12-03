//
//  TabBarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI
import CustomRouting

struct TabBarView: View {

    @State var presenter: TabBarPresenter

    var tabs: [TabBarScreen]
    
    @ViewBuilder var tabViewAccessoryView: (TabViewAccessoryDelegate) -> AnyView

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
        .tabViewBottomAccessory {
            if let active = presenter.active {
                tabViewAccessoryView(TabViewAccessoryDelegate(active: active))
            }
        }
        .task {
            _ = presenter.checkForActiveSession()
        }
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
