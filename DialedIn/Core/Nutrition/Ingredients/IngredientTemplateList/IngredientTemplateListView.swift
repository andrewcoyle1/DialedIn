//
//  IngredientTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct IngredientTemplateListDelegate {
    var templateIds: [String]
}

struct IngredientTemplateListView: View {
    @State var presenter: IngredientTemplateListPresenter
    let genericTemplateListView: (
        IngredientTemplateListPresenter,
        TemplateListConfiguration<IngredientTemplateModel>,
        Bool,
        [String]?
    ) -> AnyView

    init(
        presenter: IngredientTemplateListPresenter,
        delegate: IngredientTemplateListDelegate,
        genericTemplateListView: @escaping (
            IngredientTemplateListPresenter,
            TemplateListConfiguration<IngredientTemplateModel>,
            Bool,
            [String]?
        ) -> AnyView
    ) {
        self.presenter = presenter
        self.genericTemplateListView = genericTemplateListView
    }
    
    init(
        interactor: IngredientTemplateListInteractor,
        router: IngredientTemplateListRouter,
        delegate: IngredientTemplateListDelegate,
        genericTemplateListView: @escaping (
            IngredientTemplateListPresenter,
            TemplateListConfiguration<IngredientTemplateModel>,
            Bool,
            [String]?
        ) -> AnyView
    ) {
        self.presenter = IngredientTemplateListPresenter.create(
            interactor: interactor,
            router: router,
            delegate: delegate
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
    func ingredientTemplateListView(router: AnyRouter, delegate: IngredientTemplateListDelegate) -> some View {
        IngredientTemplateListView(
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
    func showIngredientTemplateListView(delegate: IngredientTemplateListDelegate) {
        router.showScreen(.push) { router in
            builder.ingredientTemplateListView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.ingredientTemplateListView(
            router: router, 
            delegate: IngredientTemplateListDelegate(
                templateIds: []
            )
        )
    }
}
