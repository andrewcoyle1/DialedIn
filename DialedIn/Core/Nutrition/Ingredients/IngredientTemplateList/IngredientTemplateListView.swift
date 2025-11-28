//
//  IngredientTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI
import CustomRouting

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
            .ingredient,
            true,
            presenter.templateIds
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.ingredientTemplateListView(
            router: router, 
            delegate: IngredientTemplateListDelegate(
                templateIds: []
            )
        )
    }
}
