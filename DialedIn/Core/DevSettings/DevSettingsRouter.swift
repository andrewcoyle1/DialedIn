//
//  DevSettingsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol DevSettingsRouter {
    func dismissScreen()
}

extension CoreRouter: DevSettingsRouter { }

extension OnbRouter: DevSettingsRouter { }

extension RootRouter: DevSettingsRouter { }
