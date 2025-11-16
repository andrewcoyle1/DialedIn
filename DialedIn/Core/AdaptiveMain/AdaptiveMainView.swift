//
//  AdaptiveMainView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct AdaptiveMainView: View {
    @Environment(CoreBuilder.self) private var builder
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State var viewModel: AdaptiveMainViewModel

    var body: some View {
        #if targetEnvironment(macCatalyst)
        builder.splitViewContainer(path: $viewModel.path, tab: $viewModel.tab)
        .layoutMode(.splitView)
        #else
        if horizontalSizeClass == .compact {
            let delegate = TabBarViewDelegate(path: $viewModel.path, tab: $viewModel.tab)
            builder.tabBarView(delegate: delegate)
            .layoutMode(.tabBar)
        } else {
            let delegate = SplitViewDelegate(path: $viewModel.path, tab: $viewModel.tab)
            builder.splitViewContainer(delegate: delegate)
            .layoutMode(
                .splitView
            )
        }
        #endif
    }
}
