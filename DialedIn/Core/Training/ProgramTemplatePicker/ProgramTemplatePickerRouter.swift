//
//  ProgramTemplatePickerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProgramTemplatePickerRouter: GlobalRouter {
    func showDevSettingsView()
    func dismissScreen()
    func showProgramStartConfigView(delegate: ProgramStartConfigDelegate)
    func showCustomProgramBuilderView()
    func showCreateProgramView(delegate: CreateProgramDelegate)
    func showAlert(error: Error)
}

extension CoreRouter: ProgramTemplatePickerRouter { }
