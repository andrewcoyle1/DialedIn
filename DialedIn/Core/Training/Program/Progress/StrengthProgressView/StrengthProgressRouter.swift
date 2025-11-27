//
//  StrengthProgressRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol StrengthProgressRouter {
    func showDevSettingsView()
    func dismissScreen()
}

extension CoreRouter: StrengthProgressRouter { }
