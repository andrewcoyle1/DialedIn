//
//  ExerciseTemplateListInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

protocol ExerciseTemplateListInteractor {
    func getExerciseTemplates(ids: [String], limitTo: Int) async throws -> [ExerciseModel]
}

extension CoreInteractor: ExerciseTemplateListInteractor { }
