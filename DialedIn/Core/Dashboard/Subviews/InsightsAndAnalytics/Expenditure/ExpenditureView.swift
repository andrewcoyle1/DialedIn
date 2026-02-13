//
//  ExpenditureView.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

struct ExpenditureDelegate {
}

struct ExpenditureView: View {

    @State var presenter: ExpenditurePresenter
    let delegate: ExpenditureDelegate

    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = ExpenditureDelegate()

    return RouterView { router in
        builder.expenditureView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {

    func expenditureView(router: Router, delegate: ExpenditureDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: ExpenditurePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}

extension CoreRouter {

    func showExpenditureView(delegate: ExpenditureDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.expenditureView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}
