//
//  GenderRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol GenderRouter {
    func showDevSettingsView()
    func showDateOfBirthView(delegate: DateOfBirthDelegate)
}

extension CoreRouter: GenderRouter { }
