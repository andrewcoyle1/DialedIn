//
//  HeightRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol HeightRouter {
    func showDevSettingsView()
    func showWeightView(delegate: WeightDelegate)
}

extension CoreRouter: HeightRouter { }
