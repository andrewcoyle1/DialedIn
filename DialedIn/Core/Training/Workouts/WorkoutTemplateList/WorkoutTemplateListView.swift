//
//  WorkoutTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateListView: View {
    @State var viewModel: WorkoutTemplateListViewModel
    let config: TemplateListConfiguration<WorkoutTemplateModel>

    init(viewModel: WorkoutTemplateListViewModel) {
        self.viewModel = viewModel
        self.config = viewModel.templateIds != nil ? .workout : .workout(customTitle: "Workout Templates", customEmptyDescription: "No workout templates available.")
    }
    
    init(interactor: WorkoutTemplateListInteractor, templateIds: [String]?) {
        self.config = templateIds != nil ? .workout : .workout(customTitle: "Workout Templates", customEmptyDescription: "No workout templates available.")
        self.viewModel = WorkoutTemplateListViewModel.create(
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
    WorkoutTemplateListView(
        interactor: CoreInteractor(
            container: DevPreview.shared.container
        ),
        templateIds: []
    )
    .previewEnvironment()
}
