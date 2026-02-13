//
//  StepsView.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

struct StepsDelegate {
}

struct StepsView: View {

    @State var presenter: StepsPresenter
    let delegate: StepsDelegate

    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = StepsDelegate()

    return RouterView { router in
        builder.stepsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {

    func stepsView(router: Router, delegate: StepsDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: StepsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}

extension CoreRouter {

    func showStepsView(delegate: StepsDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.stepsView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}
