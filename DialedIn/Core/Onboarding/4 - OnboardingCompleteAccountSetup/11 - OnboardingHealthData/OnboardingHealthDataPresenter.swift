//
//  OnboardingHealthDataPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingHealthDataPresenter {
    private let interactor: OnboardingHealthDataInteractor
    private let router: OnboardingHealthDataRouter

    init(
        interactor: OnboardingHealthDataInteractor,
        router: OnboardingHealthDataRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onAllowAccessPressed() {
        Task {
            interactor.trackEvent(event: Event.enableHealthKitStart)
            do {
                try await interactor.requestHealthKitAuthorisation()
                interactor.trackEvent(event: Event.enableHealthKitSuccess)
                handleNavigation()
            } catch {
                interactor.trackEvent(event: Event.enableHealthKitFail(error: error))
                router.showAlert(error: error)
            }
        }
    }
    
    func handleNavigation() {
        Task {
            try? await interactor.updateOnboardingStep(step: .healthDisclaimer)
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingHealthDisclaimerView()
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case enableHealthKitStart
        case enableHealthKitSuccess
        case enableHealthKitFail(error: Error)
        case navigate

        var eventName: String {
            switch self {
            case .enableHealthKitStart:     return "Onboarding_EnableHealthKit_Start"
            case .enableHealthKitSuccess:   return "Onboarding_EnableHealthKit_Success"
            case .enableHealthKitFail:      return "Onboarding_EnableHealthKit_Fail"
            case .navigate:                 return "Onboarding_HealthData_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .enableHealthKitFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .enableHealthKitFail:
                return .severe
            case .navigate:
                return .info
            default:
                return .analytic

            }
        }
    }
}
