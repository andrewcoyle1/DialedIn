//
//  CustomisingDietProgramRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol CustomisingDietProgramRouter {
    func showDevSettingsView()
    func showPreferredDietView()
}

extension CoreRouter: CustomisingDietProgramRouter { }
