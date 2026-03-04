//
//  CalorieFloorRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol CalorieFloorRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showCalorieDistributionView(delegate: CalorieDistributionDelegate)
}

extension CoreRouter: CalorieFloorRouter { }
