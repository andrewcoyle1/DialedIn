//
//  ExerciseTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI

struct ExerciseTemplateListViewDelegate {
    let templateIds: [String]?
}

struct ExerciseTemplateListView: View {
    @State var viewModel: ExerciseTemplateListViewModel
    let delegate: ExerciseTemplateListViewDelegate
    let config: TemplateListConfiguration<ExerciseTemplateModel>

    init(viewModel: ExerciseTemplateListViewModel, delegate: ExerciseTemplateListViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.config = delegate.templateIds != nil ? .exercise : .exercise(customTitle: "Exercise Templates")
    }
    
    var body: some View {
        GenericTemplateListView(
            viewModel: viewModel,
            configuration: config,
            templateIdsOverride: delegate.templateIds
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    return builder.exerciseTemplateListView(
        delegate: ExerciseTemplateListViewDelegate(templateIds: [])
    )
    .previewEnvironment()
}
