//
//  OnboardingCustomisingProgramViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingCustomisingProgramInteractor {
    var currentUser: UserModel? { get }
    func updateOnboardingStep(step: OnboardingStep) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingCustomisingProgramInteractor { }

@Observable
@MainActor
class OnboardingCustomisingProgramViewModel {
    private let interactor: OnboardingCustomisingProgramInteractor
    
    var showAlert: AnyAppAlert?
    var isLoading: Bool = false

    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        interactor: OnboardingCustomisingProgramInteractor
    ) {
        self.interactor = interactor
    }
    
    func navigateToPreferredDiet(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.preferredDiet)
    }
    
    func updateOnboardingStep() async {
        let target: OnboardingStep = .customiseProgram
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
    
    enum Event: LoggableEvent {
        case updateOnboardingStepStart
        case updateOnboardingStepSuccess
        case updateOnboardingStepFail(error: Error)
        
        var eventName: String {
            switch self {
            case .updateOnboardingStepStart:    return "update_onboarding_step_start"
            case .updateOnboardingStepSuccess:  return "update_onboarding_step_success"
            case .updateOnboardingStepFail:     return "update_onboarding_step_fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .updateOnboardingStepFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .updateOnboardingStepFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
