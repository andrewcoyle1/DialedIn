//
//  ProgramStartConfigRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProgramStartConfigRouter {
    func showProgramPreviewView(delegate: ProgramPreviewDelegate)
    func showDevSettingsView()
}

extension CoreRouter: ProgramStartConfigRouter { }
