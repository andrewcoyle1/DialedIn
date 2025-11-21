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
}

extension CoreRouter: OnboardingWelcomeRouter { }

@Observable
@MainActor
class OnboardingWelcomeViewModel {
    private let interactor: OnboardingWelcomeInteractor
    private let router: OnboardingWelcomeRouter

    var imageName: String = Constants.randomImage
    var showSignInView: Bool = false
    
    var path: [OnboardingPathOption] = []

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
        navigate(step: currentUser?.onboardingStep.onboardingPathOption ?? .intro)
    }

    func navigate(step: OnboardingPathOption) {
        interactor.trackEvent(event: Event.navigate(destination: step))
        path.append(step)
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "WelcomeView_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .navigate(destination: let destination):
                return destination.eventParameters
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
