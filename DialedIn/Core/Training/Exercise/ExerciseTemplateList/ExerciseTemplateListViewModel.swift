//
//  ExerciseTemplateListViewModel.swift
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
}

extension CoreRouter: ExerciseTemplateListRouter { }

// Typealias for backward compatibility
typealias ExerciseTemplateListViewModel = GenericTemplateListViewModel<ExerciseTemplateModel>

extension GenericTemplateListViewModel where Template == ExerciseTemplateModel {
    static func create(
        interactor: ExerciseTemplateListInteractor,
        router: ExerciseTemplateListRouter
    ) -> ExerciseTemplateListViewModel {
        GenericTemplateListViewModel<ExerciseTemplateModel>(
            configuration: .exercise,
            templateIds: nil,
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getExerciseTemplates(ids: ids, limitTo: limit)
            }
        )
    }
}
