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

    @ViewBuilder var tabBarView: () -> AnyView
    @ViewBuilder var splitViewContainer: () -> AnyView

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
            .layoutMode(
                .splitView
            )
        }
        #endif
    }
}
