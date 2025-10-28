//
//  OnboardingSubscriptionPlanViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

protocol OnboardingSubscriptionPlanInteractor {
    var currentUser: UserModel? { get }
    func updateOnboardingStep(step: OnboardingStep) async throws
    func purchase() async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingSubscriptionPlanInteractor { }

@Observable
@MainActor
class OnboardingSubscriptionPlanViewModel {
    private let interactor: OnboardingSubscriptionPlanInteractor
    
    var navigateToCompleteAccountSetup: Bool = false
    var selectedPlan: Plan = .annual
    var isPurchasing: Bool = false
    var showRestoreAlert: Bool = false
    var showAlert: AnyAppAlert?
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: OnboardingSubscriptionPlanInteractor
    ) {
        self.interactor = interactor
    }
    
    func setupView() async {
        let target: OnboardingStep = .subscription
        let current = interactor.currentUser?.onboardingStep
        guard current == nil || current!.orderIndex < target.orderIndex else { return }
        interactor.trackEvent(event: Event.updateOnboardingStart)
        do {
            try await interactor.updateOnboardingStep(step: target)
            interactor.trackEvent(event: Event.updateOnboardingSuccess)
        } catch {
            interactor.trackEvent(event: Event.updateOnboardingFail(error: error))
        }
    }
    
    func onRestorePressed() {
        showRestoreAlert = true
    }
    
    func onPurchase() {
        // Placeholder flow to simulate purchase
        isPurchasing = true
        Task {
            defer { isPurchasing = false }
            do {
                try await interactor.purchase()
                navigateToCompleteAccountSetup = true
            } catch {
                showAlert = AnyAppAlert(title: "Subscription Failed", subtitle: "We were unable to setup your subscription. Please try again.")
            }
        }
    }
    
    enum Event: LoggableEvent {
        case updateOnboardingStart
        case updateOnboardingSuccess
        case updateOnboardingFail(error: Error)
        
        var eventName: String {
            switch self {
            case .updateOnboardingStart:    return "OnboardingSubscription_OnboardingStepUpdate_Start"
            case .updateOnboardingSuccess:  return "OnboardingSubscription_OnboardingStepUpdate_Success"
            case .updateOnboardingFail:     return "OnboardingSubscription_OnboardingStepUpdate_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .updateOnboardingFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .updateOnboardingFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
