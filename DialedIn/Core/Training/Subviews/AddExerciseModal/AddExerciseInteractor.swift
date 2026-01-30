//
//  AddExerciseInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol AddExerciseInteractor {
    func getSystemExerciseTemplates() throws -> [ExerciseModel]
    func getTopExerciseTemplatesByClicks(limitTo: Int) async throws -> [ExerciseModel]
    func getAllLocalExerciseTemplates() throws -> [ExerciseModel]
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseModel]
}

extension CoreInteractor: AddExerciseInteractor { }
