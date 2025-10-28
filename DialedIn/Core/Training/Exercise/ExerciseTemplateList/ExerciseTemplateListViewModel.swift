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

// Typealias for backward compatibility
typealias ExerciseTemplateListViewModel = GenericTemplateListViewModel<ExerciseTemplateModel>

extension GenericTemplateListViewModel where Template == ExerciseTemplateModel {
    static func create(
        interactor: ExerciseTemplateListInteractor,
        templateIds: [String]?
    ) -> ExerciseTemplateListViewModel {
        let config: TemplateListConfiguration<ExerciseTemplateModel> = templateIds != nil ? .exercise : .exercise(customTitle: "Exercise Templates")
        return GenericTemplateListViewModel<ExerciseTemplateModel>(
            configuration: config,
            templateIds: templateIds,
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getExerciseTemplates(ids: ids, limitTo: limit)
            }
        )
    }
}
