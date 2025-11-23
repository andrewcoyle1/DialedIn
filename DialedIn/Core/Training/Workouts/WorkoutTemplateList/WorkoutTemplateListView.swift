//
//  WorkoutTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import CustomRouting

struct WorkoutTemplateListViewDelegate {
    let templateIds: [String]?
}

struct WorkoutTemplateListView: View {
    @State var viewModel: WorkoutTemplateListViewModel
    let delegate: WorkoutTemplateListViewDelegate
    let config: TemplateListConfiguration<WorkoutTemplateModel>
    let genericTemplateListView: (
        WorkoutTemplateListViewModel,
        TemplateListConfiguration<WorkoutTemplateModel>,
        Bool,
        [String]?
    ) -> AnyView

    init(
        viewModel: WorkoutTemplateListViewModel,
        delegate: WorkoutTemplateListViewDelegate,
        genericTemplateListView: @escaping (
            WorkoutTemplateListViewModel,
            TemplateListConfiguration<WorkoutTemplateModel>,
            Bool,
            [String]?
        ) -> AnyView
    ) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.config = delegate.templateIds != nil ? .workout : .workout(customTitle: "Workout Templates", customEmptyDescription: "No workout templates available.")
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
    RouterView { router in
        builder.workoutTemplateListView(
            router: router,
            delegate: WorkoutTemplateListViewDelegate(templateIds: [])
        )
    }
    .previewEnvironment()
}
