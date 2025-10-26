//
//  EditableExerciseCardWrapperViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol EditableExerciseCardWrapperInteractor {
    
}

extension CoreInteractor: EditableExerciseCardWrapperInteractor { }

@Observable
@MainActor
class EditableExerciseCardWrapperViewModel {
    private let interactor: EditableExerciseCardWrapperInteractor
    let exercise: WorkoutExerciseModel
    let index: Int
    let weightUnit: ExerciseWeightUnit
    let distanceUnit: ExerciseDistanceUnit
    let onExerciseUpdate: (WorkoutExerciseModel) -> Void
    let onAddSet: () -> Void
    let onDeleteSet: (String) -> Void
    let onWeightUnitChange: (ExerciseWeightUnit) -> Void
    let onDistanceUnitChange: (ExerciseDistanceUnit) -> Void
    
    var localExercise: WorkoutExerciseModel
    
    init(
        interactor: EditableExerciseCardWrapperInteractor,
        exercise: WorkoutExerciseModel,
        index: Int,
        weightUnit: ExerciseWeightUnit,
        distanceUnit: ExerciseDistanceUnit,
        onExerciseUpdate: @escaping (WorkoutExerciseModel) -> Void,
        onAddSet: @escaping () -> Void,
        onDeleteSet: @escaping (String) -> Void,
        onWeightUnitChange: @escaping (ExerciseWeightUnit) -> Void,
        onDistanceUnitChange: @escaping (ExerciseDistanceUnit) -> Void
    ) {
        self.interactor = interactor
        self.exercise = exercise
        self.index = index
        self.weightUnit = weightUnit
        self.distanceUnit = distanceUnit
        self.onExerciseUpdate = onExerciseUpdate
        self.onAddSet = onAddSet
        self.onDeleteSet = onDeleteSet
        self.onWeightUnitChange = onWeightUnitChange
        self.onDistanceUnitChange = onDistanceUnitChange
        self.localExercise = exercise
    }
}
