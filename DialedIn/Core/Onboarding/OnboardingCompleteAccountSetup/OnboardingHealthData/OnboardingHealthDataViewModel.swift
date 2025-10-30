//
//  OnboardingHealthDataViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingHealthDataInteractor {
    func canRequestHealthDataAuthorisation() async -> Bool
    func requestHealthKitAuthorisation() async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingHealthDataInteractor { }

@Observable
@MainActor
class OnboardingHealthDataViewModel {
    private let interactor: OnboardingHealthDataInteractor
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var showAlert: AnyAppAlert?
    var navigationDestination: NavigationDestination?
    
    enum NavigationDestination {
        case gender
        case notifications
    }
    
    init(
        interactor: OnboardingHealthDataInteractor
    ) {
        self.interactor = interactor
    }
    
    func onAllowAccessPressed() {
        Task {
            interactor.trackEvent(event: Event.enableHealthKitStart)
            do {
                try await interactor.requestHealthKitAuthorisation()
                interactor.trackEvent(event: Event.enableHealthKitSuccess)
                let canRequest = await interactor.canRequestHealthDataAuthorisation()
                navigationDestination = canRequest ? .notifications : .gender
            } catch {
                interactor.trackEvent(event: Event.enableHealthKitFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func navigateToGender(path: Binding<[OnboardingPathOption]>) {
        path.wrappedValue.append(.gender)
    }

    enum Event: LoggableEvent {
        case enableHealthKitStart
        case enableHealthKitSuccess
        case enableHealthKitFail(error: Error)

        var eventName: String {
            switch self {
            case .enableHealthKitStart:    return "Onboarding_EnableHealthKit_Start"
            case .enableHealthKitSuccess:  return "Onboarding_EnableHealthKit_Success"
            case .enableHealthKitFail:     return "Onboarding_EnableHealthKit_Fail"
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
            default:
                return .analytic

            }
        }
    }
}
