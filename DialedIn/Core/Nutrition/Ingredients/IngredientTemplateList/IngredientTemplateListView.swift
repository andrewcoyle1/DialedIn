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

    init(viewModel: IngredientTemplateListViewModel, delegate: IngredientTemplateListViewDelegate) {
        self.viewModel = viewModel
    }
    
    init(interactor: IngredientTemplateListInteractor, delegate: IngredientTemplateListViewDelegate) {
        self.viewModel = IngredientTemplateListViewModel.create(
            interactor: interactor,
            delegate: delegate
        )
    }

    var body: some View {
        GenericTemplateListView(
            viewModel: viewModel,
            configuration: .ingredient,
            supportsRefresh: true
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.ingredientTemplateListView(delegate: IngredientTemplateListViewDelegate(templateIds: []))
}
