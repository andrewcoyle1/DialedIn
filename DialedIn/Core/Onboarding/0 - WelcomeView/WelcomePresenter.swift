//
//  WelcomePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

@Observable
@MainActor
class WelcomePresenter {
    private let interactor: WelcomeInteractor
    private let router: WelcomeRouter

    var imageName: String = "SplashScreen"

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: WelcomeInteractor,
        router: WelcomeRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: WelcomeDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: WelcomeDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onContinuePressed() {
        guard let user = currentUser else {
            router.showIntroView()
            return
        }

        // isAnonymous is Bool? — treat nil (unset) the same as true
        if user.isAnonymous != false {
            router.showIntroView()
            return
        }

        if user.didCompleteOnboarding {
            if interactor.isPremium {
                router.switchToCoreModule()
            } else {
                router.showPaywall(onPurchaseSuccess: { [weak self] in
                    self?.router.switchToCoreModule()
                })
            }
            return
        }

        route(to: user.inferredOnboardingStep)
    }

    // MARK: Handle Navigation
    func handleNavigation() {
        // Navigate based on user's inferred onboarding step
        if let currentUser = interactor.currentUser {
            let step = currentUser.inferredOnboardingStep
            interactor.trackEvent(event: Event.navigate)
            route(to: step)
        }
    }

    private func route(to step: OnboardingStep) {
        switch step {
        case .auth:
            router.showAuthView()
            
        case .subscription:
            router.showSubscriptionView()

        case .completeAccountSetup:
            router.showCompleteAccountSetupView()

        case .notifications:
            router.showNotificationsPermissionsView()

        case .healthData:
            router.showOnboardingHealthDataView()

        case .healthDisclaimer:
            router.showHealthDisclaimerView()

        case .goalSetting:
            router.showGoalSettingView()

        case .gymProfileSetup:
            let delegate = CreateGymProfileDelegate(onComplete: self.handleNavigation)
            router.showCreateGymProfileView(delegate: delegate)

        case .trainingProgramSetup:
            router.showOnboardingTrainingProgramView(delegate: CreateProgramDelegate(onComplete: self.handleNavigation))
        case .customiseProgram:
            router.showOnboardingCustomisingProgramView()

        case .complete:
            router.showOnboardingCompletedView()
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

}

extension WelcomePresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: WelcomeDelegate)
        case onDisappear(delegate: WelcomeDelegate)
        case navigate

        var eventName: String {
            switch self {
            case .onAppear:     return "WelcomeView_Appear"
            case .onDisappear:  return "WelcomeView_Disappear"
            case .navigate:     return "WelcomeView_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .onAppear(delegate: let delegate), .onDisappear(delegate: let delegate):
                return delegate.eventParameters
            case .navigate:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
    }
}
