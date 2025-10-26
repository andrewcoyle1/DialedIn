//
//  OnboardingHealthDisclaimerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingHealthDisclaimerView: View {
    @Environment(DependencyContainer.self) private var container

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
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
        
    var body: some View {
        List {
            disclaimerSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Notice")
        .safeAreaInset(edge: .bottom) {
            buttonSection
        }
        .task {
            await updateOnboardingStep()
        }
        .showModal(showModal: $showModal, content: {
            confirmationModal
        })
        .showModal(showModal: $isLoading) {
            ProgressView()
                .tint(.white)
        }
        .toolbar {
            toolbarContent
        }
        .showCustomAlert(alert: $showAlert)
        .navigationDestination(isPresented: Binding(
            get: {
                if case .goalSetting = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            OnboardingGoalSettingView()
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
    }
    
    private var disclaimerSection: some View {
        Section {
            Text(disclaimerString)
        } header: {
            Text("Health Disclaimer")
        }
    }
    
    private var disclaimerString: String = """
            DialedIn is not a medical device and does not provide medical advice. The information presented is for general educational purposes only and is not a substitute for professional medical advice, diagnosis, or treatment.
            Always consult a qualified healthcare provider before starting any diet, exercise, or weight‑loss program, changing medications, or if you have questions about a medical condition. 
            If you experience chest pain, shortness of breath, dizziness, or other concerning symptoms, stop activity and seek medical attention immediately. If you believe you may be experiencing a medical emergency, call your local emergency number right away.
            """
    
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
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        if canContinue {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    onContinuePressed()
                } label: {
                    Text("Continue")
                        .padding()
                }
                .buttonStyle(.glassProminent)
                .disabled(!canContinue)
            }
        }
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
    
    private func updateOnboardingStep() async {
        let target: OnboardingStep = .healthDisclaimer
        if let current = userManager.currentUser?.onboardingStep, current.orderIndex >= target.orderIndex {
            return
        }
        isLoading = true
        logManager.trackEvent(event: Event.updateOnboardingStepStart)
        do {
            try await userManager.updateOnboardingStep(step: target)
            logManager.trackEvent(event: Event.updateOnboardingStepSuccess)
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
                                await updateOnboardingStep()
                            }
                        } label: {
                            Text("Try again")
                        }
                    }
                )
            })
            logManager.trackEvent(event: Event.updateOnboardingStepFail(error: error))
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

#Preview("Health Disclaimer") {
    NavigationStack {
        OnboardingHealthDisclaimerView()
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    NavigationStack {
        OnboardingHealthDisclaimerView()
    }
    .environment(UserManager(services: MockUserServices(user: .mock, delay: 3)))
    .previewEnvironment()
}

#Preview("Slow Failure") {
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
