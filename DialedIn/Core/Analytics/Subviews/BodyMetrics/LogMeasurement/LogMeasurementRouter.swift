//
//  LogMeasurementRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/09/2026.
//

@MainActor
protocol LogMeasurementRouter {
    func showAlert(error: Error)
    func dismissScreen()
}

extension CoreRouter: LogMeasurementRouter { }
