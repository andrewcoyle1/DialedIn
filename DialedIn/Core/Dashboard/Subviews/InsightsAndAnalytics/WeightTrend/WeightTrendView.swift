//
//  WeightTrendView.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

struct WeightTrendDelegate {
}

struct WeightTrendView: View {

    @State var presenter: WeightTrendPresenter
    let delegate: WeightTrendDelegate

    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = WeightTrendDelegate()

    return RouterView { router in
        builder.weightTrendView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {

    func weightTrendView(router: Router, delegate: WeightTrendDelegate) -> some View {
        MetricDetailView(
            presenter: WeightTrendPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}

extension CoreRouter {

    func showWeightTrendView(delegate: WeightTrendDelegate) {
        router.showScreen(.sheet) { router in
            builder.weightTrendView(router: router, delegate: delegate)
        }
    }
}
