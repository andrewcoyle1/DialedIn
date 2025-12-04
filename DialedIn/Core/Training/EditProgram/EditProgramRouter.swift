//
//  EditProgramRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol EditProgramRouter {
    func showProgramGoalsView(delegate: ProgramGoalsDelegate)
    func showProgramScheduleView(delegate: ProgramScheduleDelegate)
    func showDevSettingsView()
    func dismissScreen()

    func showAlert(title: String, subtitle: String?, buttons: @escaping @Sendable () -> AnyView)
}

extension CoreRouter: EditProgramRouter { }
