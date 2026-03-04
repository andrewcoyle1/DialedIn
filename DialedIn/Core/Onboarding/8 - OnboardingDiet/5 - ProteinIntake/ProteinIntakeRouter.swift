//
//  ProteinIntakeRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProteinIntakeRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showDietPlanView(delegate: DietPlanDelegate)
}

extension CoreRouter: ProteinIntakeRouter { }
