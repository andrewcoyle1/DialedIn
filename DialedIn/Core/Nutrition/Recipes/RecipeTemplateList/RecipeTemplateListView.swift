//
//  RecipeTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI
import CustomRouting

struct RecipeTemplateListViewDelegate {
    var templateIds: [String]
}

struct RecipeTemplateListView: View {
    @State var viewModel: RecipeTemplateListViewModel
    let genericTemplateListView: (
        RecipeTemplateListViewModel,
        TemplateListConfiguration<RecipeTemplateModel>,
        Bool,
        [String]?
    ) -> AnyView
    
    init(
        interactor: RecipeTemplateListInteractor,
        router: RecipeTemplateListRouter,
        delegate: RecipeTemplateListViewDelegate,
        genericTemplateListView: @escaping (
            RecipeTemplateListViewModel,
            TemplateListConfiguration<RecipeTemplateModel>,
            Bool,
            [String]?
        ) -> AnyView
    ) {
        self.viewModel = RecipeTemplateListViewModel.create(
            interactor: interactor,
            router: router,
            templateIds: delegate.templateIds
        )
        self.genericTemplateListView = genericTemplateListView
    }

    var body: some View {
        genericTemplateListView(
            viewModel,
            .recipe,
            true,
            viewModel.templateIds
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)

    RouterView { router in
        builder.recipeTemplateListView(
            router: router,
            delegate: RecipeTemplateListViewDelegate(templateIds: [])
        )
    }
}
