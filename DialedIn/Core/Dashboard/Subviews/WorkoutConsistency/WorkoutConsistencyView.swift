//
//  WorkoutConsistencyView.swift
//  DialedIn
//

import SwiftUI

struct WorkoutConsistencyDelegate {
}

struct WorkoutConsistencyView: View {

    @State var presenter: WorkoutConsistencyPresenter
    let delegate: WorkoutConsistencyDelegate

    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = WorkoutConsistencyDelegate()

    return RouterView { router in
        builder.workoutConsistencyView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {

    func workoutConsistencyView(router: Router, delegate: WorkoutConsistencyDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: WorkoutConsistencyPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}

extension CoreRouter {

    func showWorkoutConsistencyView(delegate: WorkoutConsistencyDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.workoutConsistencyView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}
