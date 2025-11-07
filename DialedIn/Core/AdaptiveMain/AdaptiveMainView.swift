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
    
    @State var viewModel: AdaptiveMainViewModel

    var body: some View {
        #if targetEnvironment(macCatalyst)
        SplitViewContainer(
            viewModel: SplitViewContainerViewModel(
                interactor: CoreInteractor(
                    container: container
                )
            ),
            path: $viewModel.path,
            tab: $viewModel.tab
        )
        .layoutMode(.splitView)
        #else
        if horizontalSizeClass == .compact {
            TabBarView(
                viewModel: TabBarViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                ),
                path: $viewModel.path,
                tab: $viewModel.tab
            )
            .layoutMode(.tabBar)
        } else {
            SplitViewContainer(
                viewModel: SplitViewContainerViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                ),
                path: $viewModel.path,
                tab: $viewModel.tab
            )
            .layoutMode(
                .splitView
            )
        }
        #endif
    }
}
