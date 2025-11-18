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
    let genericTemplateListView: (
        ExerciseTemplateListViewModel,
        TemplateListConfiguration<ExerciseTemplateModel>,
        Bool,
        [String]?
    ) -> AnyView

    init(
        viewModel: ExerciseTemplateListViewModel,
        delegate: ExerciseTemplateListViewDelegate,
        genericTemplateListView: @escaping (
            ExerciseTemplateListViewModel,
            TemplateListConfiguration<ExerciseTemplateModel>,
            Bool,
            [String]?
        ) -> AnyView
    ) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.config = delegate.templateIds != nil ? .exercise : .exercise(customTitle: "Exercise Templates")
        self.genericTemplateListView = genericTemplateListView
    }
    
    var body: some View {
        genericTemplateListView(
            viewModel,
            config,
            false,
            delegate.templateIds
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
