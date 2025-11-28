//
//  EditableExerciseCardWrapperPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class EditableExerciseCardWrapperPresenter {
    private let interactor: EditableExerciseCardWrapperInteractor

    // Local, mutable copy of the exercise used for editing
    var localExercise: WorkoutExerciseModel
    var index: Int
    var weightUnit: ExerciseWeightUnit
    var distanceUnit: ExerciseDistanceUnit
    
    init(
        interactor: EditableExerciseCardWrapperInteractor,
        exercise: WorkoutExerciseModel,
        index: Int,
        weightUnit: ExerciseWeightUnit,
        distanceUnit: ExerciseDistanceUnit
    ) {
        self.interactor = interactor
        self.localExercise = exercise
        self.index = index
        self.weightUnit = weightUnit
        self.distanceUnit = distanceUnit
    }
    
    func refresh(from delegate: EditableExerciseCardWrapperDelegate) {
        index = delegate.index
        weightUnit = delegate.weightUnit
        distanceUnit = delegate.distanceUnit
        // If parent updates the exercise externally and we want to reflect that,
        // uncomment the following line to overwrite the local copy:
        // localExercise = delegate.exercise
    }
}
