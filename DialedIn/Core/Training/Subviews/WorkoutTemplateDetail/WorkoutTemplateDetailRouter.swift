//
//  WorkoutTemplateDetailRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

import SwiftUI

@MainActor
protocol WorkoutTemplateDetailRouter: GlobalRouter {
    func showDevSettingsView()
    func showCreateWorkoutView(delegate: CreateWorkoutDelegate)
    func showWorkoutStartModal(delegate: WorkoutStartDelegate)
    func showWorkoutTrackerView(delegate: WorkoutTrackerDelegate)
}

extension CoreRouter: WorkoutTemplateDetailRouter { }
