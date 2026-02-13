//
//  WeighInConsistencyView.swift
//  DialedIn
//

import SwiftUI

struct WeighInConsistencyDelegate {
}

struct WeighInConsistencyView: View {

    @State var presenter: WeighInConsistencyPresenter
    let delegate: WeighInConsistencyDelegate

    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = WeighInConsistencyDelegate()

    return RouterView { router in
        builder.weighInConsistencyView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {

    func weighInConsistencyView(router: Router, delegate: WeighInConsistencyDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: WeighInConsistencyPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}

extension CoreRouter {

    func showWeighInConsistencyView(delegate: WeighInConsistencyDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.weighInConsistencyView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}
