//
//  DayScheduleSheetRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol DayScheduleSheetRouter {
    func showDevSettingsView()
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate)

    func dismissScreen()
    
    func showAlert(error: Error)
}

extension CoreRouter: DayScheduleSheetRouter { }
