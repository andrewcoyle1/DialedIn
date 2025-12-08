//
//  OnboardingHealthDisclaimerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class OnboardingHealthDisclaimerPresenter {
    private let interactor: OnboardingHealthDisclaimerInteractor
    private let router: OnboardingHealthDisclaimerRouter

    var acceptedTerms: Bool = false
    var acceptedPrivacy: Bool = false
    var showModal: Bool = false

    var canContinue: Bool { acceptedTerms && acceptedPrivacy }
        
    var disclaimerString: String = """
            DialedIn is not a medical device and does not provide medical advice. The information presented is for general educational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment.
            Always consult a qualified healthcare provider before starting any diet, exercise, or weight‑loss program, changing medications, or if you have questions about a medical condition. 
            If you experience chest pain, shortness of breath, dizziness, or other concerning symptoms, stop activity and seek medical attention immediately. If you believe you may be experiencing a medical emergency, call your local emergency number right away.
            """
    
    init(
        interactor: OnboardingHealthDisclaimerInteractor,
        router: OnboardingHealthDisclaimerRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onContinuePressed() {
        guard canContinue else { return }
        showModal = true
    }
    
    func onCancelPressed() {
        showModal = false
    }
    
    func onConfirmPressed() {
        showModal = false
        router.showLoadingModal()

        let disclaimerVersion = "2025.10.05"
        let privacyVersion = "2025.10.05"
        let now = Date()
        interactor.trackEvent(event: Event.consentHealthConfirmStart(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion))
        Task {
            do {
                try await interactor.updateHealthConsents(disclaimerVersion: disclaimerVersion, step: .goalSetting, privacyVersion: privacyVersion, acceptedAt: now)
                interactor.trackEvent(event: Event.consentHealthConfirmSuccess(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, acceptedAt: now))
                
                router.dismissModal()
                handleNavigation()
            } catch {
                interactor.trackEvent(event: Event.consentHealthConfirmFail(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, error: error))
                
                router.dismissModal()
                router.showSimpleAlert(
                    title: "Unable to save",
                    subtitle: "We were unable to save your consent. Please check your internet connection and try again."
                )
            }
        }
    }

    func handleNavigation() {
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingGoalSettingView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case consentHealthConfirmStart(disclaimerVersion: String, privacyVersion: String)
        case consentHealthConfirmSuccess(disclaimerVersion: String, privacyVersion: String, acceptedAt: Date)
        case consentHealthConfirmFail(disclaimerVersion: String, privacyVersion: String, error: Error)
        case navigate

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
            default: return nil
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
