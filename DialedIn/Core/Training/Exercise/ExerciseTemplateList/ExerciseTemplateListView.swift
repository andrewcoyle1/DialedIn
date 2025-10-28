//
//  ExerciseTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct ExerciseTemplateListView: View {
    @State var viewModel: ExerciseTemplateListViewModel
    let config: TemplateListConfiguration<ExerciseTemplateModel>
    
    init(viewModel: ExerciseTemplateListViewModel) {
        self.viewModel = viewModel
        self.config = viewModel.templateIds != nil ? .exercise : .exercise(customTitle: "Exercise Templates")
    }
    
    init(interactor: ExerciseTemplateListInteractor, templateIds: [String]?) {
        self.config = templateIds != nil ? .exercise : .exercise(customTitle: "Exercise Templates")
        self.viewModel = ExerciseTemplateListViewModel.create(
            interactor: interactor,
            templateIds: templateIds
        )
    }
    
    var body: some View {
        GenericTemplateListView(
            viewModel: viewModel,
            configuration: config
        )
    }
}

#Preview {
    ExerciseTemplateListView(
        interactor: CoreInteractor(
            container: DevPreview.shared.container
        ),
        templateIds: []
    )
}
