//
//  OnboardingNotificationsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingNotificationsPresenter {
    private let interactor: OnboardingNotificationsInteractor
    private let router: OnboardingNotificationsRouter

    var showEnablePushNotificationsModal: Bool = false
    
    init(
        interactor: OnboardingNotificationsInteractor,
        router: OnboardingNotificationsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onEnableNotificationsPressed() {
        showEnablePushNotificationsModal = true
        interactor.trackEvent(event: Event.pushNotificationsModalShow)
    }
    
    func onEnablePushNotificationsPressed() {
        showEnablePushNotificationsModal = false
        interactor.trackEvent(event: Event.enableNotificationsStart)
        Task {
            do {
                let isAuthorised = try await interactor.requestPushAuthorisation()

                interactor.trackEvent(event: Event.enableNotificationsSuccess(isAuthorised: isAuthorised))
                await handleNavigation()
            } catch {
                interactor.trackEvent(event: Event.enableNotficiationsFail(error: error))
            }
        }
    }

    private func handleNavigation() async {
        if interactor.canRequestHealthDataAuthorisation() {
            try? await interactor.updateOnboardingStep(step: .healthData)
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingHealthDataView()
        } else {
            try? await interactor.updateOnboardingStep(step: .healthDisclaimer)
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingHealthDisclaimerView()
        }
    }

    func onCancelPushNotificationsPressed() {
        interactor.trackEvent(event: Event.pushNotificationsModalDismiss)
        showEnablePushNotificationsModal = false
    }

    func onSkipForNowPressed() {
        interactor.trackEvent(event: Event.skipForNow)
        Task {
            await handleNavigation()
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case pushNotificationsModalShow
        case pushNotificationsModalDismiss
        case enableNotificationsStart
        case enableNotificationsSuccess(isAuthorised: Bool)
        case enableNotficiationsFail(error: Error)
        case skipForNow
        case navigate

        var eventName: String {
            switch self {
            case .pushNotificationsModalShow:       return "Onboarding_PushNotifsModal_Show"
            case .pushNotificationsModalDismiss:    return "Onboarding_PushNotifsModal_Dismiss"
            case .enableNotificationsStart:         return "Onboarding_EnableNotifications_Start"
            case .enableNotificationsSuccess:       return "Onboarding_EnableNotifications_Success"
            case .enableNotficiationsFail:          return "Onboarding_EnableNotifications_Fail"
            case .skipForNow:                       return "Onboarding_Notifications_SkipForNow"
            case .navigate:                       return "Onboarding_Notifications_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .enableNotificationsSuccess(isAuthorised: let isAuthorised):
                return [
                    "isAuthorised": isAuthorised
                ] as [String: Any]
            case .enableNotficiationsFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .enableNotficiationsFail:
                return .warning
            case .navigate:
                return .info
            default:
                return .analytic
            }
        }
    }
}
