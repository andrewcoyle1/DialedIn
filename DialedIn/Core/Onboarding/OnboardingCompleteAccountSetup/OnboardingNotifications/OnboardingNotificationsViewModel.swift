//
//  OnboardingNotificationsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingNotificationsInteractor {
    func requestPushAuthorisation() async throws -> Bool
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingNotificationsInteractor { }

@Observable
@MainActor
class OnboardingNotificationsViewModel {
    private let interactor: OnboardingNotificationsInteractor
    
    var showEnablePushNotificationsModal: Bool = false
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    enum NavigationDestination {
        case gender
    }
    
    init(
        interactor: OnboardingNotificationsInteractor
    ) {
        self.interactor = interactor
    }
    
    func onEnableNotificationsPressed() {
        showEnablePushNotificationsModal = true
        interactor.trackEvent(event: Event.pushNotificationsModalShow)
    }
    
    func onEnablePushNotificationsPressed(path: Binding<[OnboardingPathOption]>) {
        showEnablePushNotificationsModal = false
        interactor.trackEvent(event: Event.enableNotificationsStart)
        Task {
            do {
                let isAuthorised = try await interactor.requestPushAuthorisation()
                interactor.trackEvent(event: Event.enableNotificationsSuccess(isAuthorised: isAuthorised))
                path.wrappedValue.append(.gender)

            } catch {
                interactor.trackEvent(event: Event.enableNotficiationsFail(error: error))
            }
        }
    }

    func onCancelPushNotificationsPressed() {
        interactor.trackEvent(event: Event.pushNotificationsModalDismiss)
        showEnablePushNotificationsModal = false
    }

    func onSkipForNowPressed(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.skipForNow)
        path.wrappedValue.append(.gender)
    }

    enum Event: LoggableEvent {
        case pushNotificationsModalShow
        case pushNotificationsModalDismiss
        case enableNotificationsStart
        case enableNotificationsSuccess(isAuthorised: Bool)
        case enableNotficiationsFail(error: Error)
        case skipForNow

        var eventName: String {
            switch self {
            case .pushNotificationsModalShow: return "Onboarding_PushNotifsModal_Show"
            case .pushNotificationsModalDismiss: return "Onboarding_PushNotifsModal_Dismiss"
            case .enableNotificationsStart:    return "Onboarding_EnableNotifications_Start"
            case .enableNotificationsSuccess:  return "Onboarding_EnableNotifications_Success"
            case .enableNotficiationsFail:     return "Onboarding_EnableNotifications_Fail"
            case .skipForNow:                  return "Onboarding_Notifications_SkipForNow"
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
            default:
                return .analytic

            }
        }
    }
}
