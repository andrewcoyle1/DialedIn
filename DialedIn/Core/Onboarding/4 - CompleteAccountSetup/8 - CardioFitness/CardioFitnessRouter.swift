//
//  CardioFitnessRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol CardioFitnessRouter {
    func showDevSettingsView()
    func showExpenditureView(delegate: ExpenditureDelegate)
}

extension CoreRouter: CardioFitnessRouter { }
