//
//  ExercisePickerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ExercisePickerPresenter {
    private let interactor: ExercisePickerInteractor
    private let router: ExercisePickerRouter

    var searchText: String = ""
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    var filteredExercises: [ExerciseModel] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return allExercises }
        return allExercises.filter { exercise in
            var fields: [String] = [
                exercise.name,
                exercise.type?.name ?? ""
            ]
            if let description = exercise.description { fields.append(description) }
            fields.append(contentsOf: exercise.muscleGroups.keys.map { $0.name })
            return fields.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    var systemExercises: [ExerciseModel] {
        interactor.systemExercises
    }
    
    var userExercises: [ExerciseModel] {
        interactor.userExercises
    }
    
    var allExercises: [ExerciseModel] {
        interactor.allExercises
    }
    
    init(
        interactor: ExercisePickerInteractor,
        router: ExercisePickerRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onExercisePressed(exercise: ExerciseModel, selectedExercises: Binding<[ExerciseModel]>) {
        if let index = selectedExercises.wrappedValue.firstIndex(where: { $0.id == exercise.id }) {
            selectedExercises.wrappedValue.remove(at: index)
        } else {
            selectedExercises.wrappedValue.append(exercise)
        }
    }
        
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func dismissScreen() {
        router.dismissScreen()
    }
}
