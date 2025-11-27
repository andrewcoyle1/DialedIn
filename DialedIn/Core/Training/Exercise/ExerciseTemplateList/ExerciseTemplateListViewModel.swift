//
//  ExerciseTemplateListPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ExerciseTemplateListInteractor {
    func getExerciseTemplates(ids: [String], limitTo: Int) async throws -> [ExerciseTemplateModel]
}

extension CoreInteractor: ExerciseTemplateListInteractor { }

@MainActor
protocol ExerciseTemplateListRouter {
    func showDevSettingsView()
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: ExerciseTemplateListRouter { }

// Typealias for backward compatibility
typealias ExerciseTemplateListPresenter = GenericTemplateListPresenter<ExerciseTemplateModel>

extension GenericTemplateListPresenter where Template == ExerciseTemplateModel {
    static func create(
        interactor: ExerciseTemplateListInteractor,
        router: ExerciseTemplateListRouter
    ) -> ExerciseTemplateListPresenter {
        GenericTemplateListPresenter<ExerciseTemplateModel>(
            configuration: .exercise,
            templateIds: nil,
            showAlert: { title, subtitle in
                router.showSimpleAlert(title: title, subtitle: subtitle)
            },
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getExerciseTemplates(ids: ids, limitTo: limit)
            }
        )
    }
}
