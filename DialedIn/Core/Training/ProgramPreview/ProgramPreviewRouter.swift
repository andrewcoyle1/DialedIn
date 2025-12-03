//
//  ProgramPreviewRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProgramPreviewRouter {
    func showDevSettingsView()
}

extension CoreRouter: ProgramPreviewRouter { }
