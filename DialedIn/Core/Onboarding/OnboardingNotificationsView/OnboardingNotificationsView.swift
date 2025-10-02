//
//  OnboardingNotificationsView.swift
//  BrainBolt
//
//  Created by Assistant on 13/08/2025.
//

import SwiftUI

struct OnboardingNotificationsView: View {
    @Environment(PushManager.self) private var pushManager
    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(LogManager.self) private var logManager
    @State private var navigateNext: Bool = false

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    @State private var showEnablePushNotificationsModal: Bool = false

    var body: some View {
        List {
            justificationSection

            reassuranceSection
        }
        .safeAreaInset(edge: .bottom) {
            buttonSection
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        #if !DEBUG && !MOCK
        .navigationBarBackButtonHidden(true)
        #else
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showDebugView = true
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
        #endif
        .navigationDestination(isPresented: $navigateNext) {
            if healthKitManager.needsAuthorizationForRequiredTypes() {
                OnboardingHealthDataView()
            } else {
                OnboardingCompletedView()
            }
        }
        .screenAppearAnalytics(name: "OnboardingNotifications")
        .showModal(showModal: $showEnablePushNotificationsModal) {
            pushNotificationModal
        }
    }

    private var justificationSection: some View {
        Section {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "bell.badge.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Stay Informed & Motivated")
                        .font(.headline)
                    Text("Enable notifications to receive reminders for workouts, nutrition tracking, and important updates. Stay on track and never miss a beat in your fitness journey.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Why Enable Notifications?")
        }
    }
    
    private var reassuranceSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Label("You can change your notification preferences at any time in Settings.", systemImage: "gearshape")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Label("We respect your privacy. Notifications are only used to help you reach your goals and are never shared.", systemImage: "lock.shield")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Good to Know")
        }
    }
    
    private var buttonSection: some View {
        VStack(spacing: 12) {
            Button {
                onEnableNotificationsPressed()
            } label: {
                Text("Enable notifications")
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .buttonStyle(.glassProminent)

            Button {
                onSkipForNowPressed()
            } label: {
                Text("Not now")
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
    }

    private func onEnableNotificationsPressed() {
        showEnablePushNotificationsModal = true
        logManager.trackEvent(event: Event.pushNotificationsModalShow)
    }

    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable Push Notifications?",
            subtitle: "We will send you reminders and updates",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                onEnablePushNotificationsPressed()
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: {
                onCancelPushNotificationsPressed()
            }
        )
    }

    private func onEnablePushNotificationsPressed() {
        showEnablePushNotificationsModal = false
        logManager.trackEvent(event: Event.enableNotificationsStart)
        Task {
            do {
                let isAuthorised = try await pushManager.requestAuthorisation()
                logManager.trackEvent(event: Event.enableNotificationsSuccess(isAuthorised: isAuthorised))
                navigateNext = true

            } catch {
                logManager.trackEvent(event: Event.enableNotficiationsFail(error: error))
            }
        }
    }

    private func onCancelPushNotificationsPressed() {
        logManager.trackEvent(event: Event.pushNotificationsModalDismiss)
        showEnablePushNotificationsModal = false
    }

    private func onSkipForNowPressed() {
        logManager.trackEvent(event: Event.skipForNow)
        navigateNext = true
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

#Preview {
    NavigationStack {
        OnboardingNotificationsView()
    }
    .previewEnvironment()
}
