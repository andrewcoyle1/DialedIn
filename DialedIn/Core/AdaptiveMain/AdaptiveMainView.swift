//
//  AdaptiveMainView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct AdaptiveMainView<TabBarView: View, SplitView: View>: View {

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State var presenter: AdaptiveMainPresenter

    @ViewBuilder var tabBarView: () -> TabBarView
    @ViewBuilder var splitViewContainer: () -> SplitView

    var body: some View {
        Group {
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
        .onAppear {
            presenter.getActiveLocalWorkoutSession()
        }
    }
}

extension CoreBuilder {
    func adaptiveMainView(router: AnyRouter) -> some View {
        AdaptiveMainView(
            presenter: AdaptiveMainPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            tabBarView: {
                self.tabBarView(router: router)
                    .any()
            },
            splitViewContainer: { 
                self.splitViewContainer(router: router)
                    .any()
            }
        )
    }
}
