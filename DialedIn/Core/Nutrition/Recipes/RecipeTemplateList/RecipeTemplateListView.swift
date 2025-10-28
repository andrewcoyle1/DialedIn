//
//  RecipeTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct RecipeTemplateListView: View {
    @State var viewModel: RecipeTemplateListViewModel
    
    init(viewModel: RecipeTemplateListViewModel) {
        self.viewModel = viewModel
    }
    
    init(interactor: RecipeTemplateListInteractor, templateIds: [String]?) {
        self.viewModel = RecipeTemplateListViewModel.create(
            interactor: interactor,
            templateIds: templateIds
        )
    }
    
    // Convenience init for non-optional templateIds (backward compatibility)
    init(interactor: RecipeTemplateListInteractor, templateIds: [String]) {
        self.viewModel = RecipeTemplateListViewModel.create(
            interactor: interactor,
            templateIds: templateIds
        )
    }
    
    var body: some View {
        GenericTemplateListView(
            viewModel: viewModel,
            configuration: .recipe,
            supportsRefresh: true
        )
    }
}

#Preview {
    RecipeTemplateListView(
        interactor: CoreInteractor(container: DevPreview.shared.container),
        templateIds: []
    )
}
