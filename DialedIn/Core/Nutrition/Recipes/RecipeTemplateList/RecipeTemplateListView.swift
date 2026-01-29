//
//  RecipeTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct RecipeTemplateListView: View {
    @State var presenter: RecipeTemplateListPresenter
    let genericTemplateListView: (
        RecipeTemplateListPresenter,
        TemplateListConfiguration<RecipeTemplateModel>,
        Bool,
        [String]?
    ) -> AnyView
    
    init(
        interactor: RecipeTemplateListInteractor,
        router: RecipeTemplateListRouter,
        delegate: RecipeTemplateListDelegate,
        genericTemplateListView: @escaping (
            RecipeTemplateListPresenter,
            TemplateListConfiguration<RecipeTemplateModel>,
            Bool,
            [String]?
        ) -> AnyView
    ) {
        self.presenter = RecipeTemplateListPresenter.create(
            interactor: interactor,
            router: router,
            templateIds: delegate.templateIds
        )
        self.genericTemplateListView = genericTemplateListView
    }

    var body: some View {
        genericTemplateListView(
            presenter,
            presenter.configuration,
            true,
            presenter.templateIds
        )
    }
}

extension CoreBuilder {
    func recipeTemplateListView(router: AnyRouter, delegate: RecipeTemplateListDelegate) -> some View {
        RecipeTemplateListView(
            interactor: interactor,
            router: CoreRouter(router: router, builder: self),
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
    func showRecipeTemplateListView(delegate: RecipeTemplateListDelegate) {
        router.showScreen(.push) { router in
            builder.recipeTemplateListView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())

    RouterView { router in
        builder.recipeTemplateListView(
            router: router,
            delegate: RecipeTemplateListDelegate(templateIds: [])
        )
    }
}
