//
//  OnboardingCompleteAccountSetupRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingCompleteAccountSetupRouter {
    func showDevSettingsView()
    func showOnboardingNamePhotoView()
}

extension CoreRouter: OnboardingCompleteAccountSetupRouter { }
