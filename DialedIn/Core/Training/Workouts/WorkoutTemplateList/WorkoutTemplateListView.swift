//
//  WorkoutTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import CustomRouting

struct WorkoutTemplateListDelegate {
    let templateIds: [String]?
}

struct WorkoutTemplateListView: View {
    @State var presenter: WorkoutTemplateListPresenter
    let delegate: WorkoutTemplateListDelegate
    let config: TemplateListConfiguration<WorkoutTemplateModel>
    let genericTemplateListView: (
        WorkoutTemplateListPresenter,
        TemplateListConfiguration<WorkoutTemplateModel>,
        Bool,
        [String]?
    ) -> AnyView

    init(
        presenter: WorkoutTemplateListPresenter,
        delegate: WorkoutTemplateListDelegate,
        genericTemplateListView: @escaping (
            WorkoutTemplateListPresenter,
            TemplateListConfiguration<WorkoutTemplateModel>,
            Bool,
            [String]?
        ) -> AnyView
    ) {
        self.presenter = presenter
        self.delegate = delegate
        self.config = delegate.templateIds != nil ? .workout : .workout(customTitle: "Workout Templates", customEmptyDescription: "No workout templates available.")
        self.genericTemplateListView = genericTemplateListView
    }

    var body: some View {
        genericTemplateListView(
            presenter,
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
            delegate: WorkoutTemplateListDelegate(templateIds: [])
        )
    }
    .previewEnvironment()
}
