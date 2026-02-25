//
//  WeightRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WeightRouter {
    func showDevSettingsView()
    func showExerciseFrequencyView(delegate: ExerciseFrequencyDelegate)
}

extension CoreRouter: WeightRouter { }
