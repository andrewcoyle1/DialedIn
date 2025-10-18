//
//  AdaptiveMainView.swift
//  DialedIn
//
//  Created by AI Assistant on 18/10/2025.
//

import SwiftUI

struct AdaptiveMainView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        #if targetEnvironment(macCatalyst)
        SplitViewContainer()
            .layoutMode(.splitView)
        #else
        if UIDevice.current.userInterfaceIdiom == .phone || horizontalSizeClass == .compact {
            TabBarView()
                .layoutMode(.tabBar)
        } else {
            SplitViewContainer()
                .layoutMode(.splitView)
        }
        #endif
    }
}
