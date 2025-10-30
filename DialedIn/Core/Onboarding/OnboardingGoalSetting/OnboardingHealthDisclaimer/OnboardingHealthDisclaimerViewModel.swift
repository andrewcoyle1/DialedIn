//
//  OnboardingHealthDisclaimerViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingHealthDisclaimerInteractor {
    var currentUser: UserModel? { get }
    func updateOnboardingStep(step: OnboardingStep) async throws
    func updateHealthConsents(disclaimerVersion: String, privacyVersion: String, acceptedAt: Date) async throws
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingHealthDisclaimerInteractor { }

@Observable
@MainActor
class OnboardingHealthDisclaimerViewModel {
    private let interactor: OnboardingHealthDisclaimerInteractor
    
    var acceptedTerms: Bool = false
    var acceptedPrivacy: Bool = false
    var showModal: Bool = false
    var navigationDestination: NavigationDestination?
    var isLoading: Bool = false
    var showAlert: AnyAppAlert?

    enum NavigationDestination {
        case goalSetting
    }
    
    var canContinue: Bool { acceptedTerms && acceptedPrivacy }
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var disclaimerString: String = """
            DialedIn is not a medical device and does not provide medical advice. The information presented is for general educational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment.
            Always consult a qualified healthcare provider before starting any diet, exercise, or weight‑loss program, changing medications, or if you have questions about a medical condition. 
            If you experience chest pain, shortness of breath, dizziness, or other concerning symptoms, stop activity and seek medical attention immediately. If you believe you may be experiencing a medical emergency, call your local emergency number right away.
            """
    
    init(
        interactor: OnboardingHealthDisclaimerInteractor
    ) {
        self.interactor = interactor
    }
    
    func onContinuePressed() {
        guard canContinue else { return }
        showModal = true
        
    }
    
    func onCancelPressed() {
        showModal = false
    }
    
    func onConfirmPressed(path: Binding<[OnboardingPathOption]>) {
        showModal = false
        isLoading = true
        let disclaimerVersion = "2025.10.05"
        let privacyVersion = "2025.10.05"
        let now = Date()
        interactor.trackEvent(event: Event.consentHealthConfirmStart(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion))
        Task {
            do {
                try await interactor.updateHealthConsents(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, acceptedAt: now)
                interactor.trackEvent(event: Event.consentHealthConfirmSuccess(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, acceptedAt: now))
                isLoading = false
                path.wrappedValue.append(.goalSetting)
            } catch {
                interactor.trackEvent(event: Event.consentHealthConfirmFail(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, error: error))
                isLoading = false
                showAlert = AnyAppAlert(title: "Unable to save", subtitle: "We were unable to save your consent. Please check your internet connection and try again.")
            }
        }
    }
    
    func updateOnboardingStep() async {
        let target: OnboardingStep = .healthDisclaimer
        if let current = interactor.currentUser?.onboardingStep, current.orderIndex >= target.orderIndex {
            return
        }
        isLoading = true
        interactor.trackEvent(event: Event.updateOnboardingStepStart)
        do {
            try await interactor.updateOnboardingStep(step: target)
            interactor.trackEvent(event: Event.updateOnboardingStepSuccess)
        } catch {
            showAlert = AnyAppAlert(title: "Unable to update your progress", subtitle: "Please check your internet connection and try again.", buttons: {
                AnyView(
                    HStack {
                        Button {
                            
                        } label: {
                            Text("Dismiss")
                        }
                        
                        Button {
                            Task {
                                await self.updateOnboardingStep()
                            }
                        } label: {
                            Text("Try again")
                        }
                    }
                )
            })
            interactor.trackEvent(event: Event.updateOnboardingStepFail(error: error))
        }
        isLoading = false
    }
    
    enum Event: LoggableEvent {
        case consentHealthConfirmStart(disclaimerVersion: String, privacyVersion: String)
        case consentHealthConfirmSuccess(disclaimerVersion: String, privacyVersion: String, acceptedAt: Date)
        case consentHealthConfirmFail(disclaimerVersion: String, privacyVersion: String, error: Error)
        case updateOnboardingStepStart
        case updateOnboardingStepSuccess
        case updateOnboardingStepFail(error: Error)
        
        var eventName: String {
            switch self {
            case .consentHealthConfirmStart:    return "consent_health_confirm_start"
            case .consentHealthConfirmSuccess:  return "consent_health_confirm_success"
            case .consentHealthConfirmFail:     return "consent_health_confirm_fail"
            case .updateOnboardingStepStart:    return "update_onboarding_step_start"
            case .updateOnboardingStepSuccess:  return "update_onboarding_step_success"
            case .updateOnboardingStepFail:     return "update_onboarding_step_fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .consentHealthConfirmStart(disclaimerVersion: let disclaimerVersion, privacyVersion: let privacyVersion):
                return [
                    "disclaimer_version": disclaimerVersion,
                    "privacy_version": privacyVersion
                ]
            case .consentHealthConfirmSuccess(disclaimerVersion: let disclaimerVersion, privacyVersion: let privacyVersion, acceptedAt: let acceptedAt):
                return [
                    "disclaimer_version": disclaimerVersion,
                    "privacy_version": privacyVersion,
                    "accepted_at": acceptedAt
                ]
            case .consentHealthConfirmFail(disclaimerVersion: let disclaimerVersion, privacyVersion: let privacyVersion, error: let error):
                var dict: [String: Any] = [
                    "disclaimer_version": disclaimerVersion,
                    "privacy_version": privacyVersion
                ]
                
                for (key, value) in error.eventParameters { dict[key] = value }
                return dict
            case .updateOnboardingStepFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .consentHealthConfirmFail, .updateOnboardingStepFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
