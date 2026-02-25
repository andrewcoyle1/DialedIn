//
//  TargetWeightRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol TargetWeightRouter {
    func showDevSettingsView()
    func showWeightRateView(delegate: WeightRateDelegate)
}

extension CoreRouter: TargetWeightRouter { }
