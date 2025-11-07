//
//  OnboardingTrainingReviewViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

protocol OnboardingTrainingReviewInteractor {
    var currentUser: UserModel? { get }
    func getBuiltInTemplates() -> [ProgramTemplateModel]
    func createPlanFromTemplate(
        _ template: ProgramTemplateModel,
        startDate: Date,
        endDate: Date?,
        userId: String,
        planName: String?
    ) async throws -> TrainingPlan
    func setActivePlan(_ plan: TrainingPlan)
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingTrainingReviewInteractor { }

@Observable
@MainActor
class OnboardingTrainingReviewViewModel {
    private let interactor: OnboardingTrainingReviewInteractor
    
    var recommendedTemplate: ProgramTemplateModel?
    var isLoading: Bool = false
    var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingTrainingReviewInteractor) {
        self.interactor = interactor
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
    
    func createPlanAndContinue(path: Binding<[OnboardingPathOption]>, builder: TrainingProgramBuilder) {
        guard let template = recommendedTemplate else {
            showAlert = AnyAppAlert(
                title: "Unable to create program",
                subtitle: "Please try again"
            )
            return
        }
        
        guard let userId = interactor.currentUser?.userId else {
            showAlert = AnyAppAlert(
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
                interactor.trackEvent(event: Event.navigate(destination: .preferredDiet))
                path.wrappedValue.append(.preferredDiet)
                
            } catch {
                showAlert = AnyAppAlert(
                    title: "Unable to create program",
                    subtitle: "Please check your internet connection and try again"
                )
                interactor.trackEvent(event: Event.createPlanFail(error: error))
            }
            
            isLoading = false
        }
    }
    
    enum Event: LoggableEvent {
        case recommendationLoaded(templateId: String?, preference: ProgramPreference)
        case createPlanStart
        case createPlanSuccess(planId: String)
        case createPlanFail(error: Error)
        case navigate(destination: OnboardingPathOption)

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
            case .navigate(destination: let destination):
                return destination.eventParameters
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
