//
//  CustomProgramBuilderRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol CustomProgramBuilderRouter {
    func showProgramStartConfigView(delegate: ProgramStartConfigDelegate)
    func showWorkoutPickerView(delegate: WorkoutPickerDelegate)
    func showCopyWeekPickerView(delegate: CopyWeekPickerDelegate)
    func showDevSettingsView()
    func dismissScreen()

    func showSimpleAlert(title: String, subtitle: String?)
    func showAlert(error: Error)
}

extension CoreRouter: CustomProgramBuilderRouter { }
