//
//  OnboardingHealthDataRouter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

@MainActor
protocol OnboardingHealthDataRouter: GlobalRouter {
#if DEV || MOCK
    func showDevSettingsView()
#endif
    func showHealthDisclaimerView()
    
}

extension CoreRouter: OnboardingHealthDataRouter { }
