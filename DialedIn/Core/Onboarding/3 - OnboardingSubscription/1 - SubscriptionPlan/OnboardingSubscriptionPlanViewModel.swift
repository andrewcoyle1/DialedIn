//
//  OnboardingSubscriptionPlanViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

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
    
    init(interactor: OnboardingSubscriptionPlanInteractor) {
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
    
    func onPurchase(path: Binding<[OnboardingPathOption]>) {
        // Placeholder flow to simulate purchase
        isPurchasing = true
        Task {
            defer { isPurchasing = false }
            do {
                try await interactor.purchase()
                try await handleNavigation(path: path)
            } catch {
                showAlert = AnyAppAlert(title: "Subscription Failed", subtitle: "We were unable to setup your subscription. Please try again.")
            }
        }
    }

    func handleNavigation(path: Binding<[OnboardingPathOption]>) async throws {
        if let userStep = interactor.currentUser?.onboardingStep {
            if userStep.orderIndex > 2 {
                interactor.trackEvent(event: Event.navigate(destination: userStep.onboardingPathOption))
                path.wrappedValue.append(userStep.onboardingPathOption)
            } else {
                try await interactor.updateOnboardingStep(step: .completeAccountSetup)
                interactor.trackEvent(event: Event.navigate(destination: .completeAccount))
                path.wrappedValue.append(.completeAccount)
            }
        }
    }
    
    enum Event: LoggableEvent {
        case updateOnboardingStart
        case updateOnboardingSuccess
        case updateOnboardingFail(error: Error)
        case navigate(destination: OnboardingPathOption)
        
        var eventName: String {
            switch self {
            case .updateOnboardingStart:    return "OnboardingSubscription_OnboardingStepUpdate_Start"
            case .updateOnboardingSuccess:  return "OnboardingSubscription_OnboardingStepUpdate_Success"
            case .updateOnboardingFail:     return "OnboardingSubscription_OnboardingStepUpdate_Fail"
            case .navigate:                 return "OnboardingSubscriptionPlan_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .updateOnboardingFail(error: let error):
                return error.eventParameters
            case .navigate(destination: let destination):
                return destination.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .updateOnboardingFail:
                return .severe
            case .navigate:
                return .info
            default:
                return .analytic
                
            }
        }
    }
}

enum Plan: String, CaseIterable, Identifiable {
    case monthly
    case annual
    case lifetime
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .annual: return "Annual"
        case .lifetime: return "Lifetime"
        }
    }
    
    var subtitle: String {
        switch self {
        case .monthly: return "$9.99 / month"
        case .annual: return "$69.99 / year (save 40%)"
        case .lifetime: return "$199.99 one-time"
        }
    }
    
    var badge: String? {
        switch self {
        case .annual: return "Best Value"
        default: return nil
        }
    }
}
