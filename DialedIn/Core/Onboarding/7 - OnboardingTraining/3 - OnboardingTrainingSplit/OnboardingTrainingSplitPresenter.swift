//
//  OnboardingTrainingSplitPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

@Observable
@MainActor
class OnboardingTrainingSplitPresenter {
    private let interactor: OnboardingTrainingSplitInteractor
    private let router: OnboardingTrainingSplitRouter

    var selectedSplit: TrainingSplitType?

    init(
        interactor: OnboardingTrainingSplitInteractor,
        router: OnboardingTrainingSplitRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
    }

    func navigateToSchedule(delegate: OnboardingTrainingSplitDelegate) {
        guard let split = selectedSplit else { return }
        
        let delegate = OnboardingTrainingScheduleDelegate(delegate: delegate, trainingSplitType: split)
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingScheduleView(delegate: delegate)
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
            case .onAppear:     return "OnboardingTrainingSplitView_Appear"
            case .onDisappear:  return "OnboardingTrainingSplitView_Disappear"
            case .navigate:     return "Onboarding_TrainingSplit_Navigate"
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
