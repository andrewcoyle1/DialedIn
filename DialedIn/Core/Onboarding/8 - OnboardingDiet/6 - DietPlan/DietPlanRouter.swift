//
//  DietPlanRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol DietPlanRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showStravaConnectView()
}

extension CoreRouter: DietPlanRouter { }
