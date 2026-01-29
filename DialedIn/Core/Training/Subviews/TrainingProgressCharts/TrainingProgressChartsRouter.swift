//
//  TrainingProgressChartsRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

@MainActor
protocol TrainingProgressChartsRouter {
    func showProgressDashboardView()
}

extension CoreRouter: TrainingProgressChartsRouter { }
