//
//  DateOfBirthRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol DateOfBirthRouter {
    func showDevSettingsView()
    func showHeightView(delegate: HeightDelegate)
}

extension CoreRouter: DateOfBirthRouter { }
