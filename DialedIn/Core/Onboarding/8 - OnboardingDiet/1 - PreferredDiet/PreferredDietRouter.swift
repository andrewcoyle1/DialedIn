//
//  PreferredDietRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol PreferredDietRouter {
    func showDevSettingsView()
    func showCalorieFloorView(delegate: CalorieFloorDelegate)
}

extension CoreRouter: PreferredDietRouter { }
