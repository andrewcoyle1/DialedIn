//
//  ActivityRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ActivityRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showCardioFitnessView(delegate: CardioFitnessDelegate)
}

extension CoreRouter: ActivityRouter { }
