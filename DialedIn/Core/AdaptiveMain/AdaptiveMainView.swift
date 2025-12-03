//
//  AdaptiveMainView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct AdaptiveMainView<TabBarView: View, SplitView: View>: View {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State var presenter: AdaptiveMainPresenter

    @ViewBuilder var tabBarView: () -> TabBarView
    @ViewBuilder var splitViewContainer: () -> SplitView

    var body: some View {
        #if targetEnvironment(macCatalyst)
        splitViewContainer()
            .layoutMode(.splitView)
        #else
        if horizontalSizeClass == .compact {
            tabBarView()
                .layoutMode(.tabBar)
        } else {
            splitViewContainer()
                .layoutMode(.splitView)
        }
        #endif
    }
}
