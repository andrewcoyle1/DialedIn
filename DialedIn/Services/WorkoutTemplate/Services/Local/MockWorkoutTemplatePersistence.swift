//
//  MockExerciseTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import Foundation

@MainActor
struct MockWorkoutTemplatePersistence: LocalWorkoutTemplatePersistence {
    
    var workoutTemplates: [WorkoutTemplateModel]
    var showError: Bool
    
    init(workouts: [WorkoutTemplateModel] = WorkoutTemplateModel.mocks, showError: Bool = false) {
        self.workoutTemplates = workouts
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func addLocalWorkoutTemplate(workout: WorkoutTemplateModel) throws {
        try tryShowError()
    }
    func getLocalWorkoutTemplate(id: String) throws -> WorkoutTemplateModel {
        try tryShowError()

        if let template = workoutTemplates.first(where: { $0.id == id }) {
            return template
        } else {
            throw NSError(domain: "MockWorkoutTemplatePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "WorkoutTemplate with id \(id) not found"])
        }
    }
    func getLocalWorkoutTemplates(ids: [String]) throws -> [WorkoutTemplateModel] {
        try tryShowError()

        return workoutTemplates.filter { ids.contains($0.id) }
    }
    
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel] {
        try tryShowError()

        return workoutTemplates
    }
    
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) throws {
        try tryShowError()
        // No-op in mock; in a real implementation, this would update the bookmark status in persistent storage.
    }
    
    func favouriteWorkoutTemplate(id: String, isFavourited: Bool) throws {
        try tryShowError()
        // No-op in mock; in a real implementation, this would update the favourite status in persistent storage.
    }
}
