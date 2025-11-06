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

@Observable
@MainActor
class OnboardingWelcomeViewModel {
    private let interactor: OnboardingWelcomeInteractor
    
    var imageName: String = Constants.randomImage
    var showSignInView: Bool = false
    
    var path: [OnboardingPathOption] = []
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(interactor: OnboardingWelcomeInteractor) {
        self.interactor = interactor
    }
    
    func navToAppropriateView() {
        if let user = currentUser {
            navigate(step: user.onboardingStep.onboardingPathOption)
        } else {
            navigate(step: .intro)
        }
    }

    func navigate(step: OnboardingPathOption) {
        interactor.trackEvent(event: Event.navigate(destination: step))
        path.append(step)
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
