//
//  EnergyBalanceView.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

struct EnergyBalanceDelegate {
}

struct EnergyBalanceView: View {

    @State var presenter: EnergyBalancePresenter
    let delegate: EnergyBalanceDelegate

    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = EnergyBalanceDelegate()

    return RouterView { router in
        builder.energyBalanceView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {

    func energyBalanceView(router: Router, delegate: EnergyBalanceDelegate) -> some View {
        MetricDetailView(
            presenter: EnergyBalancePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}

extension CoreRouter {

    func showEnergyBalanceView(delegate: EnergyBalanceDelegate) {
        router.showScreen(.sheet) { router in
            builder.energyBalanceView(router: router, delegate: delegate)
        }
    }
}
