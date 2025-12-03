//
//  ProgramTemplatePickerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProgramTemplatePickerRouter {
    func showDevSettingsView()
    func dismissScreen()
    func showProgramStartConfigView(delegate: ProgramStartConfigDelegate)
    func showCustomProgramBuilderView()

    func showAlert(error: Error)
}

extension CoreRouter: ProgramTemplatePickerRouter { }
