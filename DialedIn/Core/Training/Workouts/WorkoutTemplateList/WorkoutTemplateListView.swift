//
//  WorkoutTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI

struct WorkoutTemplateListViewDelegate {
    let templateIds: [String]?
}

struct WorkoutTemplateListView: View {
    @State var viewModel: WorkoutTemplateListViewModel
    let delegate: WorkoutTemplateListViewDelegate
    let config: TemplateListConfiguration<WorkoutTemplateModel>

    init(
        viewModel: WorkoutTemplateListViewModel,
        delegate: WorkoutTemplateListViewDelegate
    ) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.config = delegate.templateIds != nil ? .workout : .workout(customTitle: "Workout Templates", customEmptyDescription: "No workout templates available.")
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
    builder.workoutTemplateListView(delegate: WorkoutTemplateListViewDelegate(templateIds: []))
    .previewEnvironment()
}
