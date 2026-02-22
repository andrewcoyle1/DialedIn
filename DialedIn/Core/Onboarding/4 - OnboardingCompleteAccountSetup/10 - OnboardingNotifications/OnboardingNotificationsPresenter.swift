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
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
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
                let isAuthorised = try await interactor.requestPushAuthorization()

                interactor.trackEvent(event: Event.enableNotificationsSuccess(isAuthorised: isAuthorised))
                await handleNavigation()
            } catch {
                interactor.trackEvent(event: Event.enableNotficiationsFail(error: error))
            }
        }
    }

    private func handleNavigation() async {
        if interactor.canRequestHealthDataAuthorisation() {
            interactor.trackEvent(event: Event.navigate)
            router.showOnboardingHealthDataView()
        } else {
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
        case onAppear
        case onDisappear
        case pushNotificationsModalShow
        case pushNotificationsModalDismiss
        case enableNotificationsStart
        case enableNotificationsSuccess(isAuthorised: Bool)
        case enableNotficiationsFail(error: Error)
        case skipForNow
        case navigate

        var eventName: String {
            switch self {
            case .onAppear:                         return "OnboardingNotificiationsView_Appear"
            case .onDisappear:                      return "OnboardingNotificiationsView_Disappear"
            case .pushNotificationsModalShow:       return "OnboardingNotificiationsView_PushNotifsModal_Show"
            case .pushNotificationsModalDismiss:    return "OnboardingNotificiationsView_PushNotifsModal_Dismiss"
            case .enableNotificationsStart:         return "OnboardingNotificiationsView_EnableNotifications_Start"
            case .enableNotificationsSuccess:       return "OnboardingNotificiationsView_EnableNotifications_Success"
            case .enableNotficiationsFail:          return "OnboardingNotificiationsView_EnableNotifications_Fail"
            case .skipForNow:                       return "OnboardingNotificiationsView_Notifications_SkipForNow"
            case .navigate:                         return "OnboardingNotificiationsView_Navigate"
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
