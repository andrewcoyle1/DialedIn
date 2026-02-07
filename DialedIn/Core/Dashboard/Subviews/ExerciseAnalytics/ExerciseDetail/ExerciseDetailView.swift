//
//  ExerciseDetailView.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

struct ExerciseDetailDelegate {
}

struct ExerciseDetailView: View {

    @State var presenter: ExerciseDetailPresenter
    let delegate: ExerciseDetailDelegate

    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = ExerciseDetailDelegate()

    return RouterView { router in
        builder.exerciseDetailView(router: router, delegate: delegate, templateId: "1", name: "Bench Press")
    }
    .previewEnvironment()
}

extension CoreBuilder {

    func exerciseDetailView(router: Router, delegate: ExerciseDetailDelegate, templateId: String, name: String) -> some View {
        MetricDetailView(
            presenter: ExerciseDetailPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                templateId: templateId,
                name: name
            )
        )
    }
}

extension CoreRouter {

    func showExerciseDetailView(templateId: String, name: String, delegate: ExerciseDetailDelegate) {
        router.showScreen(.sheet) { router in
            builder.exerciseDetailView(router: router, delegate: delegate, templateId: templateId, name: name)
        }
    }
}
