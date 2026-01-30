//
//  LocalExercisePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/01/2026.
//

protocol LocalExercisePersistence {
    func addLocalExercise(exercise: ExerciseModel) throws
    func getLocalExercise(id: String) throws -> ExerciseModel
    func getLocalExercises(ids: [String]) throws -> [ExerciseModel]
    func getAllLocalExercises() throws -> [ExerciseModel]
    func getSystemExercises() throws -> [ExerciseModel]
    func bookmarkExercise(id: String, isBookmarked: Bool) throws
    func favouriteExercise(id: String, isFavourited: Bool) throws
}
