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
            switch user.onboardingStep {
            case .auth:
                navToAuthOptions()
            case .subscription:
                navToSubscriptions()
            case .completeAccountSetup:
                navToCompleteAccount()
            case .healthDisclaimer:
                navToHealthDisclaimer()
            case .goalSetting:
                navToGoalSetting()
            case .customiseProgram:
                navToCustomiseProgram()
            case .diet:
                navToDietPlan()
            case .complete:
                navToAuthOptions()
            }
        } else {
            navToAuthOptions()
        }
    }
    
    func navToAuthOptions() {
        path.append(.authOptions)
        interactor.trackEvent(event: Event.navToAuthOptions)
    }
    
    func navToSubscriptions() {
        path.append(.subscriptionInfo)
        interactor.trackEvent(event: Event.subscriptionInfo)
    }
    
    func navToCompleteAccount() {
        path.append(.completeAccount)
        interactor.trackEvent(event: Event.completeAccount)
    }
    
    func navToHealthDisclaimer() {
        path.append(.healthDisclaimer)
        interactor.trackEvent(event: Event.healthDisclaimer)
    }
    
    func navToGoalSetting() {
        path.append(.goalSetting)
        interactor.trackEvent(event: Event.goalSetting)
    }
    
    func navToCustomiseProgram() {
        path.append(.customiseProgram)
        interactor.trackEvent(event: Event.customiseProgram)
    }
    
    func navToDietPlan() {
        path.append(.dietPlan)
        interactor.trackEvent(event: Event.dietPlan)
    }
    
    enum Event: LoggableEvent {
        case navToAuthOptions
        case subscriptionInfo
        case completeAccount
        case healthDisclaimer
        case goalSetting
        case customiseProgram
        case dietPlan
        
        var eventName: String {
            switch self {
            case .navToAuthOptions: return "WelcomeView_NavToAuthOptions"
            case .subscriptionInfo: return "WelcomeView_NavToSubscriptionInfo"
            case .completeAccount:  return "WelcomeView_NavToCompleteAccount"
            case .healthDisclaimer: return "WelcomeView_NavToHealthDisclaimer"
            case .goalSetting:      return "WelcomeView_NavToGoalSetting"
            case .customiseProgram: return "WelcomeView_NavToCustomiseProgram"
            case .dietPlan:         return "WelcomeView_NavToDietPlan"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default:
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
