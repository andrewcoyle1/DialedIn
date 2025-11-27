//
//  WorkoutTemplateListPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

// Typealias for backward compatibility
typealias WorkoutTemplateListPresenter = GenericTemplateListPresenter<WorkoutTemplateModel>

extension GenericTemplateListPresenter where Template == WorkoutTemplateModel {
    static func create(
        interactor: WorkoutTemplateListInteractor,
        router: WorkoutTemplateListRouter
    ) -> WorkoutTemplateListPresenter {
        return GenericTemplateListPresenter<WorkoutTemplateModel>(
            configuration: .workout,
            templateIds: nil,
            showAlert: { title, subtitle in
                router.showSimpleAlert(title: title, subtitle: subtitle)
            },
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getWorkoutTemplates(ids: ids, limitTo: limit)
            },
            fetchTopTemplates: { limit in
                try await interactor.getTopWorkoutTemplatesByClicks(limitTo: limit)
            }
        )
    }
}
