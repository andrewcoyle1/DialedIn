//
//  MuscleGroupDetailView.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

struct MuscleGroupDetailDelegate {
}

struct MuscleGroupDetailView: View {

    @State var presenter: MuscleGroupDetailPresenter
    let delegate: MuscleGroupDetailDelegate

    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = MuscleGroupDetailDelegate()

    return RouterView { router in
        builder.muscleGroupDetailView(router: router, delegate: delegate, muscle: .upperBack)
    }
    .previewEnvironment()
}

extension CoreBuilder {

    func muscleGroupDetailView(router: Router, delegate: MuscleGroupDetailDelegate, muscle: Muscles) -> some View {
        MetricDetailView(
            presenter: MuscleGroupDetailPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                muscle: muscle
            )
        )
    }
}

extension CoreRouter {

    func showMuscleGroupDetailView(muscle: Muscles, delegate: MuscleGroupDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.muscleGroupDetailView(router: router, delegate: delegate, muscle: muscle)
        }
    }
}
