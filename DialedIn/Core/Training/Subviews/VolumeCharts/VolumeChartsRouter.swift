//
//  VolumeChartsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol VolumeChartsRouter {
    func showDevSettingsView()
    func dismissScreen()
}

extension CoreRouter: VolumeChartsRouter { }
