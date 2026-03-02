//
//  LogShouldersMeasurementRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/02/2026.
//

@MainActor
protocol LogShouldersMeasurementRouter {
    func showAlert(error: Error)
    func dismissScreen()
}

extension CoreRouter: LogShouldersMeasurementRouter { }
