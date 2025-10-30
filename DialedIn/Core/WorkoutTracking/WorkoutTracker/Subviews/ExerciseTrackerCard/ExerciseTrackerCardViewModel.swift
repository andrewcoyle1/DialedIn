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
    
    var exercise: WorkoutExerciseModel
    var exerciseIndex: Int
    var isCurrentExercise: Bool
    var weightUnit: ExerciseWeightUnit
    var distanceUnit: ExerciseDistanceUnit
    var previousSetsByIndex: [Int: WorkoutSetModel]
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
    // Closure to get the latest exercise data from parent
    let getLatestExercise: () -> WorkoutExerciseModel?
    // Closures to get latest values for dynamic properties
    let getLatestExerciseIndex: () -> Int
    let getLatestIsCurrentExercise: () -> Bool
    let getLatestWeightUnit: () -> ExerciseWeightUnit
    let getLatestDistanceUnit: () -> ExerciseDistanceUnit
    let getLatestPreviousSets: () -> [Int: WorkoutSetModel]
    
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
        onRequestRestPicker: @escaping (String, Int?) -> Void,
        getLatestExercise: @escaping () -> WorkoutExerciseModel?,
        getLatestExerciseIndex: @escaping () -> Int,
        getLatestIsCurrentExercise: @escaping () -> Bool,
        getLatestWeightUnit: @escaping () -> ExerciseWeightUnit,
        getLatestDistanceUnit: @escaping () -> ExerciseDistanceUnit,
        getLatestPreviousSets: @escaping () -> [Int: WorkoutSetModel]
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
        self.getLatestExercise = getLatestExercise
        self.getLatestExerciseIndex = getLatestExerciseIndex
        self.getLatestIsCurrentExercise = getLatestIsCurrentExercise
        self.getLatestWeightUnit = getLatestWeightUnit
        self.getLatestDistanceUnit = getLatestDistanceUnit
        self.getLatestPreviousSets = getLatestPreviousSets
        self.notesDraft = exercise.notes ?? ""
    }
    
    func refreshExercise() {
        if let latest = getLatestExercise() {
            exercise = latest
            // Sync notes draft with updated exercise notes
            notesDraft = latest.notes ?? ""
        }
        // Refresh all other properties with latest values
        exerciseIndex = getLatestExerciseIndex()
        isCurrentExercise = getLatestIsCurrentExercise()
        weightUnit = getLatestWeightUnit()
        distanceUnit = getLatestDistanceUnit()
        previousSetsByIndex = getLatestPreviousSets()
    }
}
