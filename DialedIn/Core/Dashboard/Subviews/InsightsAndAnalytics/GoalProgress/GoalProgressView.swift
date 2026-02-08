//
//  GoalProgressView.swift
//  DialedIn
//

import SwiftUI

struct GoalProgressDelegate {
}

struct GoalProgressView: View {

    @State var presenter: GoalProgressPresenter
    let delegate: GoalProgressDelegate

    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = GoalProgressDelegate()

    return RouterView { router in
        builder.goalProgressView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {

    func goalProgressView(router: Router, delegate: GoalProgressDelegate) -> some View {
        GoalProgressView(
            presenter: GoalProgressPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {

    func showGoalProgressView(delegate: GoalProgressDelegate) {
        router.showScreen(.sheet) { router in
            builder.goalProgressView(router: router, delegate: delegate)
        }
    }
}
