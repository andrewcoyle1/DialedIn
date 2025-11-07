//
//  OnboardingNotificationsViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingNotificationsInteractor {
    func requestPushAuthorisation() async throws -> Bool
    func canRequestHealthDataAuthorisation() -> Bool
    func updateOnboardingStep(step: OnboardingStep) async throws
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
        
    init(interactor: OnboardingNotificationsInteractor) {
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
                await handleNavigation(path: path)
            } catch {
                interactor.trackEvent(event: Event.enableNotficiationsFail(error: error))
            }
        }
    }

    func handleNavigation(path: Binding<[OnboardingPathOption]>) async {
        if interactor.canRequestHealthDataAuthorisation() {
            try? await interactor.updateOnboardingStep(step: .healthData)
            interactor.trackEvent(event: Event.navigate(destination: .healthData))
            path.wrappedValue.append(.healthData)
        } else {
            try? await interactor.updateOnboardingStep(step: .healthDisclaimer)
            interactor.trackEvent(event: Event.navigate(destination: .healthDisclaimer))
            path.wrappedValue.append(.healthDisclaimer)
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
        case navigate(destination: OnboardingPathOption)

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
            case .navigate(destination: let destination):
                return destination.eventParameters
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
