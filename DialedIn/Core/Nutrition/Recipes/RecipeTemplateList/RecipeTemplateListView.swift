//
//  RecipeTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI
import CustomRouting

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

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)

    RouterView { router in
        builder.recipeTemplateListView(
            router: router,
            delegate: RecipeTemplateListDelegate(templateIds: [])
        )
    }
}
