//
//  AdaptiveMainView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct AdaptiveMainView: View {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State var viewModel: AdaptiveMainViewModel

    @ViewBuilder var tabBarView: (TabBarViewDelegate) -> AnyView
    @ViewBuilder var splitViewContainer: (SplitViewDelegate) -> AnyView

    var body: some View {
        #if targetEnvironment(macCatalyst)
        let delegate = SplitViewDelegate(path: $viewModel.path, tab: $viewModel.tab)
        splitViewContainer(delegate)
        .layoutMode(.splitView)
        #else
        if horizontalSizeClass == .compact {
            let delegate = TabBarViewDelegate(path: $viewModel.path, tab: $viewModel.tab)
            tabBarView(delegate)
            .layoutMode(.tabBar)
        } else {
            let delegate = SplitViewDelegate(path: $viewModel.path, tab: $viewModel.tab)
            splitViewContainer(delegate)
            .layoutMode(
                .splitView
            )
        }
        #endif
    }
}
