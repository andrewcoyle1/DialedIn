//
//  AdaptiveMainView.swift
//  DialedIn
//
//  Created by AI Assistant on 18/10/2025.
//

import SwiftUI

struct AdaptiveMainView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var detail = DetailNavigationModel()
    @State private var appNavigation = AppNavigationModel()

    var body: some View {
        #if targetEnvironment(macCatalyst)
        SplitViewContainer()
            .environment(detail)
            .environment(appNavigation)
            .layoutMode(.splitView)
        #else
        if horizontalSizeClass == .compact {
//            if UIDevice.current.userInterfaceIdiom == .phone || horizontalSizeClass == .compact {
            TabBarView()
                .environment(detail)
                .environment(appNavigation)
                .layoutMode(.tabBar)
        } else {
            SplitViewContainer()
                .environment(detail)
                .environment(appNavigation)
                .layoutMode(.splitView)
        }
        #endif
    }
}
