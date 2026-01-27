//
//  TabViewAccessoryRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/01/2026.
//

protocol TabViewAccessoryRouter: GlobalRouter {
    func showWorkoutTrackerView(delegate: WorkoutTrackerDelegate)
}

extension CoreRouter: TabViewAccessoryRouter {}
