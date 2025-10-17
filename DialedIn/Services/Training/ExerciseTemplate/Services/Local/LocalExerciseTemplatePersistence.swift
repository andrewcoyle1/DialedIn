//
//  LocatExerciseTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

@MainActor
protocol LocalExerciseTemplatePersistence {
    func addLocalExerciseTemplate(exercise: ExerciseTemplateModel) throws
    func getLocalExerciseTemplate(id: String) throws -> ExerciseTemplateModel
    func getLocalExerciseTemplates(ids: [String]) throws -> [ExerciseTemplateModel]
    func getAllLocalExerciseTemplates() throws -> [ExerciseTemplateModel]
    func getSystemExerciseTemplates() throws -> [ExerciseTemplateModel]
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) throws
    func favouriteExerciseTemplate(id: String, isFavourited: Bool) throws
}
