//
//  WorkoutPickerRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/12/2025.
//

@MainActor
protocol WorkoutPickerRouter {
    func dismissScreen()
    
    func showAlert(error: Error)
}

extension CoreRouter: WorkoutPickerRouter { }
