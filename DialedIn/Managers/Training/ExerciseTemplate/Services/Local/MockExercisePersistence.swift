//
//  MockExercisePersistence.swift
//  DialedIn
//
//  Created by Andrew Coyle on 30/01/2026.
//

struct MockExercisePersistence: LocalExercisePersistence {

    var exercises: [ExerciseModel]
    var showError: Bool

    init(exercises: [ExerciseModel] = ExerciseModel.mocks, showError: Bool = false) {
        self.exercises = exercises
        self.showError = showError
    }

    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }

    func addLocalExercise(exercise: ExerciseModel) throws {
        try tryShowError()
    }

    func getLocalExercise(id: String) throws -> ExerciseModel {
        try tryShowError()
        if let exercise = exercises.first(where: { $0.id == id }) {
            return exercise
        }
        throw NSError(domain: "MockExercisePersistence", code: 404, userInfo: [NSLocalizedDescriptionKey: "Exercise with id \(id) not found"])
    }

    func getLocalExercises(ids: [String]) throws -> [ExerciseModel] {
        try tryShowError()
        return exercises.filter { ids.contains($0.id) }
    }

    func getAllLocalExercises() throws -> [ExerciseModel] {
        try tryShowError()
        return exercises
    }

    func getSystemExercises() throws -> [ExerciseModel] {
        try tryShowError()
        return exercises.filter { $0.isSystemExercise }
    }

    func bookmarkExercise(id: String, isBookmarked: Bool) throws {
        try tryShowError()
    }

    func favouriteExercise(id: String, isFavourited: Bool) throws {
        try tryShowError()
    }
}
