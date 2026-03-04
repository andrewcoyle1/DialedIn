//
//  CardioFitnessRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol CardioFitnessRouter: GlobalRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showExpenditureView(delegate: ExpenditureDelegate)
}

extension CoreRouter: CardioFitnessRouter { }
