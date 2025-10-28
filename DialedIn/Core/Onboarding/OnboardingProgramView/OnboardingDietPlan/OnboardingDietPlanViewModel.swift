//
//  OnboardingDietPlanViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingDietPlanInteractor {
    var currentUser: UserModel? { get }
    func updateOnboardingStep(step: OnboardingStep) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingDietPlanInteractor { }

@Observable
@MainActor
class OnboardingDietPlanViewModel {
    private let interactor: OnboardingDietPlanInteractor
    
    var plan: DietPlan?
    var showAlert: AnyAppAlert?
    var isLoading: Bool = false
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingDietPlanInteractor
    ) {
        self.interactor = interactor
    }
    
    func updateOnboardingStep() async {
        let target: OnboardingStep = .diet
        if let current = interactor.currentUser?.onboardingStep, current.orderIndex >= target.orderIndex {
            return
        }
        isLoading = true
        interactor.trackEvent(event: Event.updateOnboardingStepStart)
        do {
            try await interactor.updateOnboardingStep(step: target)
            interactor.trackEvent(event: Event.updateOnboardingStepSuccess)
        } catch {
            showAlert = AnyAppAlert(title: "Unable to update your progress", subtitle: "Please check your internet connection and try again.", buttons: {
                AnyView(
                    HStack {
                        Button {
                            
                        } label: {
                            Text("Dismiss")
                        }
                        
                        Button {
                            Task {
                                await self.updateOnboardingStep()
                            }
                        } label: {
                            Text("Try again")
                        }
                    }
                )
            })
            interactor.trackEvent(event: Event.updateOnboardingStepFail(error: error))
        }
        isLoading = false
    }
    
    func onContinuePressed() {
        isLoading = true
        Task {
            interactor.trackEvent(event: Event.finishOnboardingStart)
            do {
                try await interactor.updateOnboardingStep(step: .complete)
                interactor.trackEvent(event: Event.finishOnboardingSuccess)
            } catch {
                showAlert = AnyAppAlert(title: "Unable to update your profile", subtitle: "Please check your internet connection and try again")
                interactor.trackEvent(event: Event.finishOnboardingFail(error: error))
            }
            isLoading = false
        }
    }
    
    enum Event: LoggableEvent {
        case updateOnboardingStepStart
        case updateOnboardingStepSuccess
        case updateOnboardingStepFail(error: Error)
        case finishOnboardingStart
        case finishOnboardingSuccess
        case finishOnboardingFail(error: Error)
        
        var eventName: String {
            switch self {
            case .updateOnboardingStepStart:    return "DietView_UpdateOnboardingStep_Start"
            case .updateOnboardingStepSuccess:  return "DietView_UpdateOnboardingStep_Success"
            case .updateOnboardingStepFail:     return "DietView_UpdateOnboardingStep_Fail"
            case .finishOnboardingStart:        return "DietView_FinishOnboarding_Start"
            case .finishOnboardingSuccess:      return "DietView_FinishOnboarding_Success"
            case .finishOnboardingFail:         return "DietView_FinishOnboarding_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishOnboardingFail(error: let error), .updateOnboardingStepFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishOnboardingFail, .updateOnboardingStepFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
