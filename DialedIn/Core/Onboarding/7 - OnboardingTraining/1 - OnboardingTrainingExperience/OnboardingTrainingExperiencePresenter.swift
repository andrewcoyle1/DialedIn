//
//  OnboardingTrainingExperiencePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

@Observable
@MainActor
class OnboardingTrainingExperiencePresenter {
    private let interactor: OnboardingTrainingExperienceInteractor
    private let router: OnboardingTrainingExperienceRouter

    var selectedLevel: TrainingExperience?
        
    init(
        interactor: OnboardingTrainingExperienceInteractor,
        router: OnboardingTrainingExperienceRouter
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
    
    func navigateToDaysPerWeek(delegate: OnboardingTrainingExperienceDelegate) {
        guard let level = selectedLevel else { return }
        
        let delegate = OnboardingTrainingDaysPerWeekDelegate(delegate: delegate, trainingExperience: level)
        
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingTrainingDaysPerWeekView(delegate: delegate)
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
            case .onAppear:     return "OnboardingTrainingExperienceView_Appear"
            case .onDisappear:  return "OnboardingTrainingExperienceView_Disappear"
            case .navigate:     return "Onboarding_TrainingExperience_Navigate"
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

enum TrainingExperience: CaseIterable {
    case beginner
    case intermediate
    case advanced
    
    var name: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
    
    var description: String {
        switch self {
        case .beginner: return "Less than 1 year of training consistently."
        case .intermediate: return "1-3 years of training consistently."
        case .advanced: return "3+ years of training consistently."
        }
    }
}
