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
        
    init(interactor: OnboardingHealthDataInteractor) {
        self.interactor = interactor
    }
    
    func onAllowAccessPressed(path: Binding<[OnboardingPathOption]>) {
        Task {
            interactor.trackEvent(event: Event.enableHealthKitStart)
            do {
                try await interactor.requestHealthKitAuthorisation()
                interactor.trackEvent(event: Event.enableHealthKitSuccess)
                handleNavigation(path: path)
            } catch {
                interactor.trackEvent(event: Event.enableHealthKitFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func handleNavigation(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .healthDisclaimer))
        path.wrappedValue.append(.healthDisclaimer)
    }

    enum Event: LoggableEvent {
        case enableHealthKitStart
        case enableHealthKitSuccess
        case enableHealthKitFail(error: Error)
        case navigate(destination: OnboardingPathOption)

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
            case .navigate(destination: let destination):
                return destination.eventParameters
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
