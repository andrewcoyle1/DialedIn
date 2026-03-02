//
//  LogRightForearmMeasurementRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/02/2026.
//

@MainActor
protocol LogRightForearmMeasurementRouter {
    func showAlert(error: Error)
    func dismissScreen()
}

extension CoreRouter: LogRightForearmMeasurementRouter { }
