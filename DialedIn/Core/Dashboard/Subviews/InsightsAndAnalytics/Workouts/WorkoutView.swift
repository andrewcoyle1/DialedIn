//
//  WorkoutView.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

struct WorkoutDelegate {
}

struct WorkoutView: View {

    @State var presenter: WorkoutPresenter
    let delegate: WorkoutDelegate

    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = WorkoutDelegate()

    return RouterView { router in
        builder.workoutView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {

    func workoutView(router: Router, delegate: WorkoutDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: WorkoutPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}

extension CoreRouter {

    func showWorkoutView(delegate: WorkoutDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.workoutView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}
