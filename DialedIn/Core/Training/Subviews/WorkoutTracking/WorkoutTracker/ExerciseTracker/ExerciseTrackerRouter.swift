//
//  ExerciseTrackerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/03/2026.
//

@MainActor
protocol ExerciseTrackerRouter: GlobalRouter {
    func showWarmupSetInfoModal(primaryButtonAction: @escaping () -> Void)
}

extension CoreRouter: ExerciseTrackerRouter { }
