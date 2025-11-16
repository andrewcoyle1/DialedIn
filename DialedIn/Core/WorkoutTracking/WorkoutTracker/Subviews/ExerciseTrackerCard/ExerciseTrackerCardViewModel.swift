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
        previousSetsByIndex: [Int: WorkoutSetModel]
    ) {
        self.interactor = interactor
        self.exercise = exercise
        self.exerciseIndex = exerciseIndex
        self.isCurrentExercise = isCurrentExercise
        self.weightUnit = weightUnit
        self.distanceUnit = distanceUnit
        self.previousSetsByIndex = previousSetsByIndex
        self.notesDraft = exercise.notes ?? ""
    }
    
    func refresh(
        with exercise: WorkoutExerciseModel,
        exerciseIndex: Int,
        isCurrentExercise: Bool,
        weightUnit: ExerciseWeightUnit,
        distanceUnit: ExerciseDistanceUnit,
        previousSetsByIndex: [Int: WorkoutSetModel]
    ) {
        self.exercise = exercise
        self.exerciseIndex = exerciseIndex
        self.isCurrentExercise = isCurrentExercise
        self.weightUnit = weightUnit
        self.distanceUnit = distanceUnit
        self.previousSetsByIndex = previousSetsByIndex
        // Sync notes draft with updated exercise notes
        notesDraft = exercise.notes ?? ""
    }
}
