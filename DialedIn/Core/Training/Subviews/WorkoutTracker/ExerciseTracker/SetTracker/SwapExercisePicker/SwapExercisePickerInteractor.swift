//
//  SwapExercisePickerInteractor.swift
//  DialedIn
//

@MainActor
protocol SwapExercisePickerInteractor: GlobalInteractor {
    var allExercises: [ExerciseModel] { get }
}

extension CoreInteractor: SwapExercisePickerInteractor {}
