//
//  ExerciseTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ExerciseTemplateListDelegate {
    let templateIds: [String]?
}

struct ExerciseTemplateListView: View {
    @State var presenter: ExerciseTemplateListPresenter
    let delegate: ExerciseTemplateListDelegate
    let genericTemplateListView: (
        ExerciseTemplateListPresenter,
        TemplateListConfiguration<ExerciseModel>,
        Bool,
        [String]?
    ) -> AnyView

    init(
        presenter: ExerciseTemplateListPresenter,
        delegate: ExerciseTemplateListDelegate,
        genericTemplateListView: @escaping (
            ExerciseTemplateListPresenter,
            TemplateListConfiguration<ExerciseModel>,
            Bool,
            [String]?
        ) -> AnyView
    ) {
        self.presenter = presenter
        self.delegate = delegate
        self.genericTemplateListView = genericTemplateListView
    }
    
    var body: some View {
        genericTemplateListView(
            presenter,
            presenter.configuration,
            false,
            delegate.templateIds
        )
    }
}

extension CoreBuilder {
    func exerciseTemplateListView(router: AnyRouter, delegate: ExerciseTemplateListDelegate) -> some View {
        ExerciseTemplateListView(
            presenter: ExerciseTemplateListPresenter.create(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                templateIds: delegate.templateIds
            ),
            delegate: delegate,
            genericTemplateListView: { presenter, configuration, supportsRefresh, templateIdsOverride in
                self.genericTemplateListView(
                    presenter: presenter,
                    configuration: configuration,
                    supportsRefresh: supportsRefresh,
                    templateIdsOverride: templateIdsOverride
                )
                .any()
            }
        )
    }
}

extension CoreRouter {
    func showExerciseTemplateListView(delegate: ExerciseTemplateListDelegate) {
        router.showScreen(.push) { router in
            builder.exerciseTemplateListView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.exerciseTemplateListView(
            router: router, 
            delegate: ExerciseTemplateListDelegate(templateIds: [])
        )
    }
    .previewEnvironment()
}
