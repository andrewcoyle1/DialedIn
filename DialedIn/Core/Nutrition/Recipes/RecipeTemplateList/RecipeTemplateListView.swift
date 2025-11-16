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
    
    init(interactor: RecipeTemplateListInteractor, delegate: RecipeTemplateListViewDelegate) {
        self.viewModel = RecipeTemplateListViewModel.create(
            interactor: interactor,
            templateIds: delegate.templateIds
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
        delegate: RecipeTemplateListViewDelegate(templateIds: [])
    )
}
