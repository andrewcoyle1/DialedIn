//
//  OnboardingSubscriptionPlanPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingSubscriptionPlanPresenter {
    private let interactor: OnboardingSubscriptionPlanInteractor
    private let router: OnboardingSubscriptionPlanRouter

    var selectedPlan: Plan = .annual
    var isPurchasing: Bool = false
    var showRestoreAlert: Bool = false

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: OnboardingSubscriptionPlanInteractor,
        router: OnboardingSubscriptionPlanRouter
    ) {
        self.interactor = interactor
        self.router = router
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
        router.showSimpleAlert(title: "Restore Purchases", subtitle: "Restoring purchases is not yet implemented.")
    }
    
    func onPurchase() {
        // Placeholder flow to simulate purchase
        isPurchasing = true
        Task {
            defer { isPurchasing = false }
            do {
                try await interactor.purchase()
                try await handleNavigation()
            } catch {
                router.showSimpleAlert(title: "Subscription Failed", subtitle: "We were unable to setup your subscription. Please try again.")
            }
        }
    }

    func handleNavigation() async throws {
        guard let userStep = interactor.currentUser?.onboardingStep else { return }

        if userStep.orderIndex > OnboardingStep.completeAccountSetup.orderIndex {
            interactor.trackEvent(event: Event.navigate)
            route(to: userStep)
        } else {
            do {
                try await interactor.updateOnboardingStep(step: .completeAccountSetup)
                interactor.trackEvent(event: Event.navigate)
                route(to: .completeAccountSetup)
            } catch {
                interactor.trackEvent(event: Event.updateOnboardingFail(error: error))
                throw error
            }
        }
    }
    
    private func route(to step: OnboardingStep) {
        switch step {
        case .auth, .subscription:
            // For anything at/before subscription, move them into complete-account setup
            router.showOnboardingCompleteAccountSetupView()

        case .completeAccountSetup:
            router.showOnboardingCompleteAccountSetupView()

        case .notifications:
            router.showOnboardingNotificationsView()

        case .healthData:
            router.showOnboardingHealthDataView()

        case .healthDisclaimer:
            router.showOnboardingHealthDisclaimerView()

        case .goalSetting:
            router.showOnboardingGoalSettingView()

        case .customiseProgram:
            router.showOnboardingCustomisingProgramView()

        case .complete:
            router.showOnboardingCompletedView()
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    
    enum Event: LoggableEvent {
        case updateOnboardingStart
        case updateOnboardingSuccess
        case updateOnboardingFail(error: Error)
        case navigate
        
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
            case .navigate:
                return nil
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
