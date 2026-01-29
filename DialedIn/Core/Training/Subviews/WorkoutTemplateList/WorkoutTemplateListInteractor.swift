//
//  WorkoutTemplateListInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol WorkoutTemplateListInteractor {
    func getWorkoutTemplates(ids: [String], limitTo: Int) async throws -> [WorkoutTemplateModel]
    func getTopWorkoutTemplatesByClicks(limitTo: Int) async throws -> [WorkoutTemplateModel]
}

extension CoreInteractor: WorkoutTemplateListInteractor { }
