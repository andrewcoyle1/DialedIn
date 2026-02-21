//
//  OnboardingWelcomePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

@Observable
@MainActor
class OnboardingWelcomePresenter {
    private let interactor: OnboardingWelcomeInteractor
    private let router: OnboardingWelcomeRouter

    var imageName: String = Constants.randomImage

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: OnboardingWelcomeInteractor,
        router: OnboardingWelcomeRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear(delegate: OnboardingWelcomeDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
    }
    
    func onViewDisappear(delegate: OnboardingWelcomeDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
    }

    func onContinuePressed() {
        
    }

    func navToAppropriateView() {
        if let step = currentUser?.onboardingStep {
            navigate(step: step)
        } else {
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingIntroView()
        }
    }

    func navigate(step: OnboardingStep) {
        interactor.trackEvent(event: Event.navigate)
        switch step {
        case .auth:
            router.showOnboardingAuthView()
            
        case .subscription:
            router.showSubscriptionView()

        case .completeAccountSetup:
            router.showOnboardingCompleteAccountSetupView()

        case .notifications:
            router.showOnboardingNotificationsView()

        case .healthData:
            router.showOnboardingHealthDataView()

        case .healthDisclaimer:
            router.showOnboardingHealthDisclaimerView()

        case .goalSetting:
            router.showOnboardingGoalSettingView()

        case .customiseProgram:
            router.showOnboardingCustomisingProgramView()

        case .complete:
            router.showOnboardingCompletedView()
        }    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

}

extension OnboardingWelcomePresenter {
    
    enum Event: LoggableEvent {
        case onAppear(delegate: OnboardingWelcomeDelegate)
        case onDisappear(delegate: OnboardingWelcomeDelegate)
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
