//
//  RecipeTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

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

    return builder.recipeTemplateListView(
        delegate: RecipeTemplateListViewDelegate(templateIds: [])
    )
}
