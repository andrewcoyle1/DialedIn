//
//  SetTrackerRowRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol SetTrackerRowRouter {
    func showDevSettingsView()
    func showWarmupSetInfoModal(primaryButtonAction: @escaping () -> Void)
    func dismissModal()
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: SetTrackerRowRouter { }
