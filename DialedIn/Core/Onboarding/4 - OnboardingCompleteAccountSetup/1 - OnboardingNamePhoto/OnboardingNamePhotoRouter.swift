//
//  OnboardingNamePhotoRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingNamePhotoRouter {
    func showDevSettingsView()
    func showOnboardingGenderView()
    func showSimpleAlert(title: String, subtitle: String?)
}

extension CoreRouter: OnboardingNamePhotoRouter { }
