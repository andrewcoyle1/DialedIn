//
//  ExerciseTrackerCardViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol ExerciseTrackerCardInteractor {
    
}

extension CoreInteractor: ExerciseTrackerCardInteractor { }

@Observable
@MainActor
class ExerciseTrackerCardViewModel {
    private let interactor: ExerciseTrackerCardInteractor
    
    let exercise: WorkoutExerciseModel
    let exerciseIndex: Int
    let isCurrentExercise: Bool
    let weightUnit: ExerciseWeightUnit
    let distanceUnit: ExerciseDistanceUnit
    let previousSetsByIndex: [Int: WorkoutSetModel]
    let onSetUpdate: (WorkoutSetModel) -> Void
    let onAddSet: () -> Void
    let onDeleteSet: (String) -> Void
    let onHeaderLongPress: () -> Void
    let onNotesChange: (String) -> Void
    let onWeightUnitChange: (ExerciseWeightUnit) -> Void
    let onDistanceUnitChange: (ExerciseDistanceUnit) -> Void
    // Rest configuration for the next set (child set) keyed by set id
    let restBeforeSecForSet: (String) -> Int?
    let onRestBeforeChange: (String, Int?) -> Void
    let onRequestRestPicker: (String, Int?) -> Void
    
    var notesDraft: String = ""

    var completedSetsCount: Int {
        exercise.sets.filter { $0.completedAt != nil }.count
    }
    
    init(
        interactor: ExerciseTrackerCardInteractor,
        exercise: WorkoutExerciseModel,
        exerciseIndex: Int,
        isCurrentExercise: Bool,
        weightUnit: ExerciseWeightUnit,
        distanceUnit: ExerciseDistanceUnit,
        previousSetsByIndex: [Int: WorkoutSetModel],
        onSetUpdate: @escaping (WorkoutSetModel) -> Void,
        onAddSet: @escaping () -> Void,
        onDeleteSet: @escaping (String) -> Void,
        onHeaderLongPress: @escaping () -> Void,
        onNotesChange: @escaping (String) -> Void,
        onWeightUnitChange: @escaping (ExerciseWeightUnit) -> Void,
        onDistanceUnitChange: @escaping (ExerciseDistanceUnit) -> Void,
        restBeforeSecForSet: @escaping (String) -> Int?,
        onRestBeforeChange: @escaping (String, Int?) -> Void,
        onRequestRestPicker: @escaping (String, Int?) -> Void
    ) {
        self.interactor = interactor
        self.exercise = exercise
        self.exerciseIndex = exerciseIndex
        self.isCurrentExercise = isCurrentExercise
        self.weightUnit = weightUnit
        self.distanceUnit = distanceUnit
        self.previousSetsByIndex = previousSetsByIndex
        self.onSetUpdate = onSetUpdate
        self.onAddSet = onAddSet
        self.onDeleteSet = onDeleteSet
        self.onHeaderLongPress = onHeaderLongPress
        self.onNotesChange = onNotesChange
        self.onWeightUnitChange = onWeightUnitChange
        self.onDistanceUnitChange = onDistanceUnitChange
        self.restBeforeSecForSet = restBeforeSecForSet
        self.onRestBeforeChange = onRestBeforeChange
        self.onRequestRestPicker = onRequestRestPicker
    }
}
