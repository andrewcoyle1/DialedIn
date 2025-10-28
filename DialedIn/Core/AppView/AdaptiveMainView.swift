//
//  AdaptiveMainView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI

struct AdaptiveMainView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var detail = DetailNavigationModel()
    @State private var appNavigation = AppNavigationModel()

    var body: some View {
        #if targetEnvironment(macCatalyst)
        SplitViewContainer(
            viewModel: SplitViewContainerViewModel(interactor: CoreInteractor(container: container)),
            detail: detail,
            appNavigation: appNavigation
        )
        .layoutMode(.splitView)
        #else
        if horizontalSizeClass == .compact {
            TabBarView(
                viewModel: TabBarViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
            .environment(detail)
            .environment(appNavigation)
            .layoutMode(.tabBar)
        } else {
            SplitViewContainer(
                viewModel: SplitViewContainerViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                ),
                detail: detail,
                appNavigation: appNavigation
            )
            .layoutMode(
                .splitView
            )
        }
        #endif
    }
}
