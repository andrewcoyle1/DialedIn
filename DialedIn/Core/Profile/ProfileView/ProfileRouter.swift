//
//  ProfileRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol ProfileRouter: GlobalRouter {
    func showProfileEditView()
    func showSettingsView()
    func showNotificationsView()
    func showExercisesView()

}

extension CoreRouter: ProfileRouter { }
