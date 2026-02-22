//
//  OnboardingTrainingEquipmentPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

@Observable
@MainActor
class OnboardingTrainingEquipmentPresenter {
    private let interactor: OnboardingTrainingEquipmentInteractor
    private let router: OnboardingTrainingEquipmentRouter

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var gymProfile: GymProfileModel = GymProfileModel(authorId: "")
    
    init(
        interactor: OnboardingTrainingEquipmentInteractor,
        router: OnboardingTrainingEquipmentRouter
    ) {
        self.interactor = interactor
        self.router = router
        
        self.gymProfile.authorId = currentUser?.userId ?? ""
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    func navigateToReview(delegate: OnboardingTrainingEquipmentDelegate) {
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingReviewView(delegate: OnboardingTrainingReviewDelegate(delegate: delegate, gymProfile: gymProfile))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case navigate

        var eventName: String {
            switch self {
            case .onAppear:     return "OnboardingTrainingEquipmentView_Appear"
            case .onDisappear:  return "OnboardingTrainingEquipmentView_Disappear"
            case .navigate:     return "OnboardingTrainingEquipmentView_Navigate"
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
            case .navigate:
                return .info
            default:
                return .analytic
            }
        }
    }
}
