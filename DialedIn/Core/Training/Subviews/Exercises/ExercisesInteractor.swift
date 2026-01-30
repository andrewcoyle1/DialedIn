//
//  ExercisesInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/11/2025.
//

protocol ExercisesInteractor {
    var currentUser: UserModel? { get }
    func incrementExerciseTemplateInteraction(id: String) async throws
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseModel]
    func getExerciseTemplates(ids: [String], limitTo: Int) async throws -> [ExerciseModel]
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseModel]
    func getSystemExerciseTemplates() throws -> [ExerciseModel]
    func getTopExerciseTemplatesByClicks(limitTo: Int) async throws -> [ExerciseModel]
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ExercisesInteractor { }
