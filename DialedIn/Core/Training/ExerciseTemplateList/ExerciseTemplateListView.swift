//
//  ExerciseTemplateListView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 17/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ExerciseTemplateListDelegate {
    let templateIds: [String]?
}

struct ExerciseTemplateListView: View {
    @State var presenter: ExerciseTemplateListPresenter
    let delegate: ExerciseTemplateListDelegate
    let genericTemplateListView: (
        ExerciseTemplateListPresenter,
        TemplateListConfiguration<ExerciseTemplateModel>,
        Bool,
        [String]?
    ) -> AnyView

    init(
        presenter: ExerciseTemplateListPresenter,
        delegate: ExerciseTemplateListDelegate,
        genericTemplateListView: @escaping (
            ExerciseTemplateListPresenter,
            TemplateListConfiguration<ExerciseTemplateModel>,
            Bool,
            [String]?
        ) -> AnyView
    ) {
        self.presenter = presenter
        self.delegate = delegate
        self.genericTemplateListView = genericTemplateListView
    }
    
    var body: some View {
        genericTemplateListView(
            presenter,
            presenter.configuration,
            false,
            delegate.templateIds
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.exerciseTemplateListView(
            router: router, 
            delegate: ExerciseTemplateListDelegate(templateIds: [])
        )
    }
    .previewEnvironment()
}
