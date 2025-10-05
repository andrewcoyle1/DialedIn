//
//  OnboardingHealthData.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct OnboardingHealthDataView: View {
    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(LogManager.self) private var logManager
    @State private var navigateNext: Bool = false

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    @State private var showAlert: AnyAppAlert?

    var body: some View {
        List {
            Section {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "scalemass")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Why We Request Health Data Access")
                            .font(.headline)
                        Text("Dialed needs permission to read and write your weight data in Apple Health. This allows us to automatically track your progress, update your weight logs, and provide you with accurate charts and insights.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Your Health, Your Data")
            }

            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Sync your weight entries seamlessly between Dialed and Apple Health.", systemImage: "arrow.triangle.2.circlepath")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Label("See all your progress in one place, even if you use other health apps.", systemImage: "chart.line.uptrend.xyaxis")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Label("Let Dialed update your Health data when you log new weights.", systemImage: "plus.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("What You Get")
            }

            Section {
                Label("Maintain full control: you can revoke access or limit permissions at any time in the Health app.", systemImage: "lock.shield")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Your Control")
            }
        }
        .navigationTitle("Health Data")
        .navigationBarTitleDisplayMode(.large)
        .showCustomAlert(alert: $showAlert)
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
            OnboardingCompletedView()
        }
        .screenAppearAnalytics(name: "OnboardingHealthData")
        .safeAreaInset(edge: .bottom) {
            buttonSection
                .padding(.horizontal)
        }
    }
    
    private var buttonSection: some View {
        VStack(spacing: 12) {
            Button {
                onAllowAccessPressed()
            } label: {
                Text("Allow access to health data")
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .buttonStyle(.glassProminent)

            Button {
                onSkipForNowPressed()
            } label: {
                Text("Skip for now")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func onAllowAccessPressed() {
        Task {
            logManager.trackEvent(event: Event.enableHealthKitStart)
            do {
                try await healthKitManager.requestAuthorization()
                logManager.trackEvent(event: Event.enableHealthKitSuccess)
                navigateNext = true
            } catch {
                logManager.trackEvent(event: Event.enableHealthKitFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    private func onSkipForNowPressed() {
        logManager.trackEvent(event: Event.skipForNow)
        navigateNext = true
    }
    enum Event: LoggableEvent {
        case enableHealthKitStart
        case enableHealthKitSuccess
        case enableHealthKitFail(error: Error)
        case skipForNow

        var eventName: String {
            switch self {
            case .enableHealthKitStart:    return "Onboarding_EnableHealthKit_Start"
            case .enableHealthKitSuccess:  return "Onboarding_EnableHealthKit_Success"
            case .enableHealthKitFail:     return "Onboarding_EnableHealthKit_Fail"
            case .skipForNow:              return "Onboarding_EnableHealthKit_Skip"
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

#Preview {
    NavigationStack {
        OnboardingHealthDataView()
    }
    .previewEnvironment()
}
