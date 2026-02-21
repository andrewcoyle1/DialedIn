//
//  OnboardingTrainingReviewPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

@Observable
@MainActor
class OnboardingTrainingReviewPresenter {
    private let interactor: OnboardingTrainingReviewInteractor
    private let router: OnboardingTrainingReviewRouter

    init(
        interactor: OnboardingTrainingReviewInteractor,
        router: OnboardingTrainingReviewRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
        
    func createPlanAndContinue() {

    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case recommendationLoaded(templateId: String?)
        case createPlanStart
        case createPlanSuccess(planId: String)
        case createPlanFail(error: Error)
        case navigate

        var eventName: String {
            switch self {
            case .recommendationLoaded: return "Onboarding_TrainingReview_RecommendationLoaded"
            case .createPlanStart: return "Onboarding_TrainingReview_CreatePlan_Start"
            case .createPlanSuccess: return "Onboarding_TrainingReview_CreatePlan_Success"
            case .createPlanFail: return "Onboarding_TrainingReview_CreatePlan_Fail"
            case .navigate: return "Onboarding_TrainingReview_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .recommendationLoaded(templateId: let templateId):
                return [
                    "templateId": templateId as Any
                ]
            case .createPlanSuccess(planId: let planId):
                return ["planId": planId]
            case .createPlanFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .createPlanFail:
                return .severe
            case .navigate:
                return .info
            default:
                return .analytic
            }
        }
    }
}
