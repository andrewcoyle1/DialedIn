//
//  AddExerciseInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol AddExerciseInteractor {
    func getSystemExerciseTemplates() throws -> [ExerciseTemplateModel]
    func getTopExerciseTemplatesByClicks(limitTo: Int) async throws -> [ExerciseTemplateModel]
    func getAllLocalExerciseTemplates() throws -> [ExerciseTemplateModel]
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseTemplateModel]
}

extension CoreInteractor: AddExerciseInteractor { }
