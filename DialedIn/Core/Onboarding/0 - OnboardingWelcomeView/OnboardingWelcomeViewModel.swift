//
//  OnboardingWelcomeViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingWelcomeInteractor {
    var currentUser: UserModel? { get }
    var onboardingStep: OnboardingStep { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingWelcomeInteractor { }

@MainActor
protocol OnboardingWelcomeRouter {
    func showDevSettingsView()
    func showOnboardingIntroView()
    func showAuthOptionsView()
    func showSubscriptionView()
    func showOnboardingCompleteAccountSetupView()
    func showOnboardingNotificationsView()
    func showOnboardingHealthDataView()
    func showOnboardingHealthDisclaimerView()
    func showOnboardingGoalSettingView()
    func showOnboardingCustomisingProgramView()
    func showOnboardingCompletedView()
}

extension CoreRouter: OnboardingWelcomeRouter { }

@Observable
@MainActor
class OnboardingWelcomeViewModel {
    private let interactor: OnboardingWelcomeInteractor
    private let router: OnboardingWelcomeRouter

    var imageName: String = Constants.randomImage
    var showSignInView: Bool = false

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
            router.showAuthOptionsView()
            
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

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "WelcomeView_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .info
            }
        }
    }
}
