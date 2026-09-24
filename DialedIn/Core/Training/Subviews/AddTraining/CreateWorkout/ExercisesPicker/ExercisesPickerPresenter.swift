//
//  ExercisesPickerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ExercisesPickerPresenter {
    private let interactor: ExercisesPickerInteractor
    private let router: ExercisesPickerRouter

    private let committedExercises: Binding<[WorkoutTemplateExercise]>
    private(set) var workingExercises: [WorkoutTemplateExercise] = []
    
    init(
        interactor: ExercisesPickerInteractor,
        router: ExercisesPickerRouter,
        delegate: ExercisesPickerDelegate
    ) {
        self.interactor = interactor
        self.router = router
        self.committedExercises = delegate.addedExercises
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    /// Reopening the picker started from an empty selection, so an exercise already in the
    /// workout could be added a second time.
    func onSavePressed() {
        let existing = Set(committedExercises.wrappedValue.map(\.exercise.id))
        committedExercises.wrappedValue.append(contentsOf: workingExercises.filter { !existing.contains($0.exercise.id) })
        router.dismissScreen()
    }

    func onExercisePressed(exercise: ExerciseModel) {
        if let index = workingExercises.firstIndex(where: { $0.exercise.id == exercise.id }) {
            workingExercises.remove(at: index)
        } else {
            let workoutExercise = WorkoutTemplateExercise(exercise: exercise, setRestTimers: false)
            workingExercises.append(workoutExercise)
        }
    }

}
