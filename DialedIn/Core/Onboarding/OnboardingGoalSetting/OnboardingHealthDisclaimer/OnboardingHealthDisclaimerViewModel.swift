//
//  OnboardingHealthDisclaimerViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingHealthDisclaimerInteractor {
    var currentUser: UserModel? { get }
    func updateHealthConsents(disclaimerVersion: String, step: OnboardingStep, privacyVersion: String, acceptedAt: Date) async throws
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
    var isLoading: Bool = false
    var showAlert: AnyAppAlert?
    
    var canContinue: Bool { acceptedTerms && acceptedPrivacy }
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var disclaimerString: String = """
            DialedIn is not a medical device and does not provide medical advice. The information presented is for general educational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment.
            Always consult a qualified healthcare provider before starting any diet, exercise, or weight‑loss program, changing medications, or if you have questions about a medical condition. 
            If you experience chest pain, shortness of breath, dizziness, or other concerning symptoms, stop activity and seek medical attention immediately. If you believe you may be experiencing a medical emergency, call your local emergency number right away.
            """
    
    init(interactor: OnboardingHealthDisclaimerInteractor) {
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
                try await interactor.updateHealthConsents(disclaimerVersion: disclaimerVersion, step: .goalSetting, privacyVersion: privacyVersion, acceptedAt: now)
                interactor.trackEvent(event: Event.consentHealthConfirmSuccess(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, acceptedAt: now))
                isLoading = false
                handleNavigation(path: path)
            } catch {
                interactor.trackEvent(event: Event.consentHealthConfirmFail(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, error: error))
                isLoading = false
                showAlert = AnyAppAlert(title: "Unable to save", subtitle: "We were unable to save your consent. Please check your internet connection and try again.")
            }
        }
    }

    func handleNavigation(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .goalSetting))
        path.wrappedValue.append(.goalSetting)
    }
    
    enum Event: LoggableEvent {
        case consentHealthConfirmStart(disclaimerVersion: String, privacyVersion: String)
        case consentHealthConfirmSuccess(disclaimerVersion: String, privacyVersion: String, acceptedAt: Date)
        case consentHealthConfirmFail(disclaimerVersion: String, privacyVersion: String, error: Error)
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .consentHealthConfirmStart:    return "consent_health_confirm_start"
            case .consentHealthConfirmSuccess:  return "consent_health_confirm_success"
            case .consentHealthConfirmFail:     return "consent_health_confirm_fail"
            case .navigate:                     return "HealthDisclaimer_Navigate"
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
            case .navigate(destination: let destination):
                return destination.eventParameters
            }
        }
        
        var type: LogType {
            switch self {
            case .consentHealthConfirmFail:
                return .severe
            case .navigate:
                return .info
            default:
                return .analytic
                
            }
        }
    }
}
