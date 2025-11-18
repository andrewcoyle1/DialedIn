//
//  IngredientTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct IngredientTemplateListViewDelegate {
    var templateIds: [String]
}

struct IngredientTemplateListView: View {
    @State var viewModel: IngredientTemplateListViewModel
    let genericTemplateListView: (
        IngredientTemplateListViewModel,
        TemplateListConfiguration<IngredientTemplateModel>,
        Bool,
        [String]?
    ) -> AnyView

    init(
        viewModel: IngredientTemplateListViewModel,
        delegate: IngredientTemplateListViewDelegate,
        genericTemplateListView: @escaping (
            IngredientTemplateListViewModel,
            TemplateListConfiguration<IngredientTemplateModel>,
            Bool,
            [String]?
        ) -> AnyView
    ) {
        self.viewModel = viewModel
        self.genericTemplateListView = genericTemplateListView
    }
    
    init(
        interactor: IngredientTemplateListInteractor,
        delegate: IngredientTemplateListViewDelegate,
        genericTemplateListView: @escaping (
            IngredientTemplateListViewModel,
            TemplateListConfiguration<IngredientTemplateModel>,
            Bool,
            [String]?
        ) -> AnyView
    ) {
        self.viewModel = IngredientTemplateListViewModel.create(
            interactor: interactor,
            delegate: delegate
        )
        self.genericTemplateListView = genericTemplateListView
    }

    var body: some View {
        genericTemplateListView(
            viewModel,
            .ingredient,
            true,
            viewModel.templateIds
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.ingredientTemplateListView(
        delegate: IngredientTemplateListViewDelegate(
            templateIds: []
        )
    )
}
