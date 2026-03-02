//
//  ExercisePickerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ExercisePickerInteractor {
    var systemExercises: [ExerciseModel] { get }
    var userExercises: [ExerciseModel] { get }
    var allExercises: [ExerciseModel] { get }
}

extension CoreInteractor: ExercisePickerInteractor { }
