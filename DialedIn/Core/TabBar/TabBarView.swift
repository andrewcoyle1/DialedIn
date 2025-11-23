//
//  TabBarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/5/24.
//

import SwiftUI
import CustomRouting

struct TabBarScreen: Identifiable {
    var id: String {
        title
    }

    let title: String
    let systemImage: String
    @ViewBuilder var screen: () -> AnyView
}

struct TabBarView: View {

    @State var viewModel: TabBarViewModel

    var tabs: [TabBarScreen]
    
    @ViewBuilder var tabViewAccessoryView: (TabViewAccessoryViewDelegate) -> AnyView

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
            if let active = viewModel.active {
                tabViewAccessoryView(TabViewAccessoryViewDelegate(active: active))
            }
        }
        .task {
            _ = viewModel.checkForActiveSession()
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
