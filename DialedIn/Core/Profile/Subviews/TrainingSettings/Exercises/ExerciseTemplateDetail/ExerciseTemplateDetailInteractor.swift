//
//  ExerciseTemplateDetailInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

@MainActor
protocol ExerciseTemplateDetailInteractor {
    var currentUser: UserModel? { get }
    func getPreference(templateId: String) -> ExerciseUnitPreference
    func getExerciseHistoryForAuthor(authorId: String, limitTo: Int) async throws -> [ExerciseHistoryEntryModel]
    func getLocalExerciseHistoryForTemplate(templateId: String, limitTo: Int) throws -> [ExerciseHistoryEntryModel]
}

extension CoreInteractor: ExerciseTemplateDetailInteractor { }
