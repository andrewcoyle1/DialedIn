//
//  ExerciseTemplateListPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

// Typealias for backward compatibility
typealias ExerciseTemplateListPresenter = GenericTemplateListPresenter<ExerciseTemplateModel>

extension GenericTemplateListPresenter where Template == ExerciseTemplateModel {
    static func create(
        interactor: ExerciseTemplateListInteractor,
        router: ExerciseTemplateListRouter,
        templateIds: [String]?
    ) -> ExerciseTemplateListPresenter {
        let baseConfig: TemplateListConfiguration<ExerciseTemplateModel> = templateIds != nil
            ? .exercise
            : .exercise(customTitle: "Exercise Templates")
            
        let configuration = baseConfig.with(navigationDestination: { template in
            router.showExerciseTemplateDetailView(delegate: ExerciseTemplateDetailDelegate(exerciseTemplate: template))
        })
            
        return GenericTemplateListPresenter<ExerciseTemplateModel>(
            configuration: configuration,
            templateIds: templateIds,
            showAlert: { title, subtitle in
                router.showSimpleAlert(title: title, subtitle: subtitle)
            },
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getExerciseTemplates(ids: ids, limitTo: limit)
            }
        )
    }
}
