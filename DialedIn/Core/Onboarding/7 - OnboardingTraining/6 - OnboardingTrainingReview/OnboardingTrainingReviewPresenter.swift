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

    var recommendedTemplate: ProgramTemplateModel?
    var isLoading: Bool = false

    init(
        interactor: OnboardingTrainingReviewInteractor,
        router: OnboardingTrainingReviewRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadRecommendation(builder: TrainingProgramBuilder) {
        guard builder.isValid else { return }
        
        let availableTemplates = interactor.getBuiltInTemplates()
        let preference = builder.programPreference
        
        recommendedTemplate = TrainingProgramRecommender.recommendTemplate(
            preference: preference,
            availableTemplates: availableTemplates
        )
        
        interactor.trackEvent(event: Event.recommendationLoaded(
            templateId: recommendedTemplate?.id,
            preference: preference
        ))
    }
    
    func createPlanAndContinue(builder: TrainingProgramBuilder) {
        guard let template = recommendedTemplate else {
            router.showSimpleAlert(
                title: "Unable to create program",
                subtitle: "Please try again"
            )
            return
        }
        
        guard let userId = interactor.currentUser?.userId else {
            router.showSimpleAlert(
                title: "User not found",
                subtitle: "Please sign in and try again"
            )
            return
        }
        
        isLoading = true
        
        Task {
            interactor.trackEvent(event: Event.createPlanStart)
            
            do {
                let plan = try await interactor.createPlanFromTemplate(
                    template,
                    startDate: builder.startDate,
                    endDate: nil,
                    userId: userId,
                    planName: nil
                )
                
                interactor.setActivePlan(plan)
                interactor.trackEvent(event: Event.createPlanSuccess(planId: plan.planId))
                
                // Navigate to diet flow
                interactor.trackEvent(event: Event.navigate)
                router.showOnboardingCustomisingProgramView()

            } catch {
                router.showSimpleAlert(
                    title: "Unable to create program",
                    subtitle: "Please check your internet connection and try again"
                )
                interactor.trackEvent(event: Event.createPlanFail(error: error))
            }
            
            isLoading = false
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case recommendationLoaded(templateId: String?, preference: ProgramPreference)
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
            case .recommendationLoaded(templateId: let templateId, preference: let preference):
                return [
                    "templateId": templateId as Any,
                    "experienceLevel": preference.experienceLevel.rawValue,
                    "targetDaysPerWeek": preference.targetDaysPerWeek,
                    "splitType": preference.splitType.rawValue
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
