//
//  MockExerciseTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import Foundation

@MainActor
struct MockExerciseTemplatePersistence: LocalExerciseTemplatePersistence {
    
    var exerciseTemplates: [ExerciseTemplateModel]
    var showError: Bool
    
    init(exercises: [ExerciseTemplateModel] = ExerciseTemplateModel.mocks, showError: Bool = false) {
        self.exerciseTemplates = exercises
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func addLocalExerciseTemplate(exercise: ExerciseTemplateModel) throws {
        try tryShowError()
    }
    func getLocalExerciseTemplate(id: String) throws -> ExerciseTemplateModel {
        try tryShowError()

        if let template = exerciseTemplates.first(where: { $0.id == id }) {
            return template
        } else {
            throw NSError(domain: "MockExerciseTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "ExerciseTemplate with id \(id) not found"])
        }
    }
    func getLocalExerciseTemplates(ids: [String]) throws -> [ExerciseTemplateModel] {
        try tryShowError()

        return exerciseTemplates.filter { ids.contains($0.id) }
    }
    
    func getAllLocalExerciseTemplates() throws -> [ExerciseTemplateModel] {
        try tryShowError()

        return exerciseTemplates
    }
    
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) throws {
        try tryShowError()
        // No-op in mock; in a real implementation, this would update the bookmark status in persistent storage.
    }
    
    func favouriteExerciseTemplate(id: String, isFavourited: Bool) throws {
        try tryShowError()
        // No-op in mock; in a real implementation, this would update the favourite status in persistent storage.
    }
}
