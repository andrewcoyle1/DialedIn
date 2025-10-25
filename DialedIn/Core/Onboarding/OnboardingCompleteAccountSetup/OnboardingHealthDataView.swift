//
//  OnboardingHealthData.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI

struct OnboardingHealthDataView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(LogManager.self) private var logManager
    @Environment(PushManager.self) private var pushManager

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    @State private var showAlert: AnyAppAlert?
    
    @State private var navigationDestination: NavigationDestination?
        
    enum NavigationDestination {
        case gender
        case notifications
    }

    var body: some View {
        List {
            yourHealthYourDataSection
            whatYouGetSection
            yourControlSection
        }
        .navigationTitle("Health Data")
        .navigationBarTitleDisplayMode(.large)
        .showCustomAlert(alert: $showAlert)
        #if !DEBUG && !MOCK
        .navigationBarBackButtonHidden(true)
        #else
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
        }
        #endif
        .toolbar {
            toolbarContent
        }
        .navigationDestination(isPresented: Binding(
            get: { navigationDestination == .notifications },
            set: { if !$0 { navigationDestination = nil } }
        )) { OnboardingNotificationsView() }
        .navigationDestination(isPresented: Binding(
            get: { navigationDestination == .gender },
            set: { if !$0 { navigationDestination = nil } }
        )) { OnboardingGenderView() }
        .screenAppearAnalytics(name: "OnboardingHealthData")
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
        ToolbarItem(placement: .bottomBar) {
            Button {
                onAllowAccessPressed()
            } label: {
                Text("Allow access to health data")
                    .padding(.horizontal)
            }
            .buttonStyle(.glassProminent)
        }
        ToolbarSpacer(.fixed, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            NavigationLink {
                OnboardingGenderView()
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }

    private var yourHealthYourDataSection: some View {
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
    }
    
    private var whatYouGetSection: some View {
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
    }
    
    private var yourControlSection: some View {
        Section {
            Label("Maintain full control: you can revoke access or limit permissions at any time in the Health app.", systemImage: "lock.shield")
                .font(.footnote)
                .foregroundStyle(.secondary)
        } header: {
            Text("Your Control")
        }
    }

    private func onAllowAccessPressed() {
        Task {
            logManager.trackEvent(event: Event.enableHealthKitStart)
            do {
                try await healthKitManager.requestAuthorisation()
                logManager.trackEvent(event: Event.enableHealthKitSuccess)
                let canRequest = await pushManager.canRequestAuthorisation()
                navigationDestination = canRequest ? .notifications : .gender
            } catch {
                logManager.trackEvent(event: Event.enableHealthKitFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
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

#Preview("Proceed to Notifications") {
    NavigationStack {
        OnboardingHealthDataView()
    }
    .previewEnvironment()
}

#Preview("Proceed to Gender") {
    NavigationStack {
        OnboardingHealthDataView()
    }
    .environment(PushManager(services: MockPushServices(canRequestAuthorisation: false)))
    .previewEnvironment()
}
