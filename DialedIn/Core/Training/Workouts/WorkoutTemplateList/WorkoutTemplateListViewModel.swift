//
//  WorkoutTemplateListViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol WorkoutTemplateListInteractor {
    func getWorkoutTemplates(ids: [String], limitTo: Int) async throws -> [WorkoutTemplateModel]
    func getTopWorkoutTemplatesByClicks(limitTo: Int) async throws -> [WorkoutTemplateModel]
}

extension CoreInteractor: WorkoutTemplateListInteractor { }

// Typealias for backward compatibility
typealias WorkoutTemplateListViewModel = GenericTemplateListViewModel<WorkoutTemplateModel>

extension GenericTemplateListViewModel where Template == WorkoutTemplateModel {
    static func create(
        interactor: WorkoutTemplateListInteractor,
        templateIds: [String]?
    ) -> WorkoutTemplateListViewModel {
        let config: TemplateListConfiguration<WorkoutTemplateModel> = templateIds != nil 
            ? .workout 
            : .workout(customTitle: "Workout Templates", customEmptyDescription: "No workout templates available.")
        return GenericTemplateListViewModel<WorkoutTemplateModel>(
            configuration: config,
            templateIds: templateIds,
            fetchTemplatesByIds: { ids, limit in
                try await interactor.getWorkoutTemplates(ids: ids, limitTo: limit)
            },
            fetchTopTemplates: { limit in
                try await interactor.getTopWorkoutTemplatesByClicks(limitTo: limit)
            }
        )
    }
}
