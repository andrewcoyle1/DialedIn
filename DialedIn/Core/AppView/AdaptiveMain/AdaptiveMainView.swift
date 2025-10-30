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
            detail: viewModel.detail,
            appNavigation: viewModel.appNavigation,
            path: viewModel.path
        )
        .layoutMode(.splitView)
        #else
        if horizontalSizeClass == .compact {
            TabBarView(
                viewModel: TabBarViewModel(
                    interactor: CoreInteractor(
                        container: container
                    ),
                    appNavigation: viewModel.appNavigation
                )
            )
            .environment(viewModel.detail)
            .environment(viewModel.appNavigation)
            .layoutMode(.tabBar)
        } else {
            SplitViewContainer(
                viewModel: SplitViewContainerViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                ),
                detail: viewModel.detail,
                appNavigation: viewModel.appNavigation
            )
            .layoutMode(
                .splitView
            )
        }
        #endif
    }
}
