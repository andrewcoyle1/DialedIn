//
//  OnboardingHealthDisclaimerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingHealthDisclaimerView: View {
    
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @State private var acceptedTerms: Bool = false
    @State private var acceptedPrivacy: Bool = false
    @State private var showModal: Bool = false
    @State private var navigationDestination: NavigationDestination?

    @State private var isLoading: Bool = false
    
    @State private var showAlert: AnyAppAlert?
    enum NavigationDestination {
        case goalSetting
    }
    
    private var canContinue: Bool { acceptedTerms && acceptedPrivacy }
    
    var body: some View {
        List {
            disclaimerSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Notice")
        .safeAreaInset(edge: .bottom) {
            buttonSection
        }
        .showModal(showModal: $showModal, content: {
            confirmationModal
        })
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: Binding(
            get: { isLoading },
            set: { _ in }
        )) {
            ProgressView()
                .tint(.white)
        }
        .navigationDestination(isPresented: Binding(
            get: {
                if case .goalSetting = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            OnboardingGoalSettingView()
        }
    }
    
    private var disclaimerSection: some View {
        Section {
            Text("""
            DialedIn is not a medical device and does not provide medical advice. The information presented is for general educational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment.

            Always consult a qualified healthcare provider before starting any diet, exercise, or weight‑loss program, changing medications, or if you have questions about a medical condition. If you experience chest pain, shortness of breath, dizziness, or other concerning symptoms, stop activity and seek medical attention immediately. If you believe you may be experiencing a medical emergency, call your local emergency number right away.
            """)
        } header: {
            Text("Health Disclaimer")
        }
    }
    
    private var buttonSection: some View {
        VStack {
            Toggle(isOn: $acceptedTerms) {
                Text("I acknowledge and accept the Terms of the Health Disclaimer")
                    .font(.callout)
            }
            Toggle(isOn: $acceptedPrivacy) {
                Text("I acknowledge and accept the Terms of the Consumer Health Privacy Notice")
                    .font(.callout)
            }
            Capsule()
                .frame(height: AuthConstants.buttonHeight)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.accent)
                .overlay(alignment: .center) {
                    Text("Continue")
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 32)
                }
                .opacity(canContinue ? 1 : 0.5)
                .allowsHitTesting(canContinue)
                .animation(.easeInOut(duration: 0.2), value: canContinue)
                .anyButton(.press) {
                    onContinuePressed()
                }
                .padding(.top)
        }
        .padding()
        .background(.bar)
    }
    
    private var confirmationModal: some View {
        CustomModalView(
            title: "Confirm and Continue",
            subtitle: """
            By continuing, you confirm that:
            • You have read and accept the Health Disclaimer.
            • You have read and accept the Consumer Health Privacy Notice.

            You understand DialedIn does not provide medical advice and is for educational use only. You can review these terms at any time in Settings.
            """,
            primaryButtonTitle: "I Agree & Continue",
            primaryButtonAction: { onConfirmPressed() },
            secondaryButtonTitle: "Go Back",
            secondaryButtonAction: { onCancelPressed() }
        )
    }
    
    private func onContinuePressed() {
        guard canContinue else { return }
        showModal = true
        
    }
    
    private func onCancelPressed() {
        showModal = false
    }
    
    private func onConfirmPressed() {
        showModal = false
        isLoading = true
        let disclaimerVersion = "2025.10.05"
        let privacyVersion = "2025.10.05"
        let now = Date()
        logManager.trackEvent(event: Event.consentHealthConfirmStart(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion))
        Task {
            do {
                try await userManager.updateHealthConsents(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, acceptedAt: now)
                logManager.trackEvent(event: Event.consentHealthConfirmSuccess(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, acceptedAt: now))
                isLoading = false
                navigationDestination = .goalSetting
            } catch {
                logManager.trackEvent(event: Event.consentHealthConfirmFail(disclaimerVersion: disclaimerVersion, privacyVersion: privacyVersion, error: error))
                isLoading = false
                showAlert = AnyAppAlert(title: "Unable to save", subtitle: "We were unable to save your consent. Please check your internet connection and try again.")
            }
        }
    }
    
    enum Event: LoggableEvent {
        case consentHealthConfirmStart(disclaimerVersion: String, privacyVersion: String)
        case consentHealthConfirmSuccess(disclaimerVersion: String, privacyVersion: String, acceptedAt: Date)
        case consentHealthConfirmFail(disclaimerVersion: String, privacyVersion: String, error: Error)
        
        var eventName: String {
            switch self {
            case .consentHealthConfirmStart: return "consent_health_confirm_start"
            case .consentHealthConfirmSuccess: return "consent_health_confirm_success"
            case .consentHealthConfirmFail: return "consent_health_confirm_fail"
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
            }
        }
        
        var type: LogType {
            switch self {
            case .consentHealthConfirmFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingHealthDisclaimerView()
    }
    .previewEnvironment()
}

#Preview("Slow Loading - Success") {
    NavigationStack {
        OnboardingHealthDisclaimerView()
    }
    .environment(UserManager(services: MockUserServices(user: .mock, delay: 3)))
    .previewEnvironment()
}

#Preview("Slow Loading - Failure") {
    NavigationStack {
        OnboardingHealthDisclaimerView()
    }
    .environment(UserManager(services: MockUserServices(user: .mock, delay: 3, showError: true)))
    .previewEnvironment()
}

#Preview("Failure") {
    NavigationStack {
        OnboardingHealthDisclaimerView()
    }
    .environment(UserManager(services: MockUserServices(user: .mock, showError: true)))
    .previewEnvironment()
}
