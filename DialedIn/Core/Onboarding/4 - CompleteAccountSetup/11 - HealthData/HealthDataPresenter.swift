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
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
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
    
    private func handleNavigation() {
        interactor.trackEvent(event: Event.navigate)
        router.showHealthDisclaimerView()
    }
    
    func onSkipForNowPressed() {
        handleNavigation()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case enableHealthKitStart
        case enableHealthKitSuccess
        case enableHealthKitFail(error: Error)
        case navigate

        var eventName: String {
            switch self {
            case .onAppear:                 return "OnboardingHealthDataView_Appear"
            case .onDisappear:              return "OnboardingHealthDataView_Disappear"
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
