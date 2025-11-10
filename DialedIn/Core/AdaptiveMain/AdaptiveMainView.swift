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
            builder.tabBarView(path: $viewModel.path, tab: $viewModel.tab)
            .layoutMode(.tabBar)
        } else {
            builder.splitViewContainer(path: $viewModel.path, tab: $viewModel.tab)
            .layoutMode(
                .splitView
            )
        }
        #endif
    }
}
