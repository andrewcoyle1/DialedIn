//
//  LocatExerciseTemplatePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

protocol LocalWorkoutTemplatePersistence {
    func addLocalWorkoutTemplate(workout: WorkoutTemplateModel) throws
    func getLocalWorkoutTemplate(id: String) throws -> WorkoutTemplateModel
    func getLocalWorkoutTemplates(ids: [String]) throws -> [WorkoutTemplateModel]
    func getAllLocalWorkoutTemplates() throws -> [WorkoutTemplateModel]
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) throws
    func deleteLocalWorkoutTemplate(id: String) throws
}
