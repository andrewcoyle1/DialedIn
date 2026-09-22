//
//  WelcomeRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol WelcomeRouter: OnboardingStepRouter {
#if DEV || MOCK
func showDevSettingsView()
#endif
    func showPaywall(isOnboarding: Bool)
    func showIntroView()
    func showAuthView()
    func showSubscriptionView()
    func switchToCoreModule()
}

extension CoreRouter: WelcomeRouter { }
