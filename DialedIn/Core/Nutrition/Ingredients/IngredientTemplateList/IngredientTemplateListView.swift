//
//  IngredientTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct IngredientTemplateListView: View {
    @State var viewModel: IngredientTemplateListViewModel
    
    init(viewModel: IngredientTemplateListViewModel) {
        self.viewModel = viewModel
    }
    
    init(interactor: IngredientTemplateListInteractor, templateIds: [String]?) {
        self.viewModel = IngredientTemplateListViewModel.create(
            interactor: interactor,
            templateIds: templateIds
        )
    }
    
    // Convenience init for non-optional templateIds (backward compatibility)
    init(interactor: IngredientTemplateListInteractor, templateIds: [String]) {
        self.viewModel = IngredientTemplateListViewModel.create(
            interactor: interactor,
            templateIds: templateIds
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
    IngredientTemplateListView(
        interactor: CoreInteractor(container: DevPreview.shared.container),
        templateIds: []
    )
}
