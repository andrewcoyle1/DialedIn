//
//  WorkoutPickerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

@MainActor
protocol WorkoutPickerInteractor: GlobalInteractor {
    var allWorkoutTemplates: [WorkoutTemplateModel] { get }
}

extension CoreInteractor: WorkoutPickerInteractor {
}
