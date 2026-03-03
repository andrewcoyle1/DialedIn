//
//  WorkoutSessionRowRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/02/2026.
//

@MainActor
protocol WorkoutSessionRowRouter: GlobalRouter {
    func showWorkoutSessionDetailView(delegate: WorkoutSessionDetailDelegate)
    func showSocialProfileView(delegate: SocialProfileDelegate)
}

extension CoreRouter: WorkoutSessionRowRouter { }
