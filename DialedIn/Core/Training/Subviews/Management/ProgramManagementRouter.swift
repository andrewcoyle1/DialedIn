//
//  ProgramManagementRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol ProgramManagementRouter: GlobalRouter {
    func showDevSettingsView()
    func showEditProgramView(delegate: EditProgramDelegate)
    func showProgramSettingsView(program: Binding<TrainingProgram>)
    func showCreateProgramView(delegate: CreateProgramDelegate)
}

extension CoreRouter: ProgramManagementRouter { }
