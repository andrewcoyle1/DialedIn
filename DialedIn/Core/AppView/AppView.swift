//
//  AppView.swift
//  BrainBolt
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI
import SwiftfulUtilities
@preconcurrency import FirebaseFunctions

struct AppView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(PushManager.self) private var pushManager
    @Environment(HealthKitManager.self) private var healthKitManager
    @State var appState: AppState = AppState()
        
    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            ), content: {
                AppViewBuilder(
                    showTabBar: appState.showTabBar,
                    tabBarView: {
                        TabBarView()
                    },
                    onboardingView: {
                        OnboardingRouterView()
                    }
                )
                .environment(appState)
                .task {
                    await checkUserStatus()
                }
                .task {
                    try? await Task.sleep(for: .seconds(2))
                    await showATTPromptIfNeeded()
                }
                .onFirstAppear {
                    schedulePushNotifications()
                }
                .onChange(of: appState.showTabBar) { _, showTabBar in
                    if !showTabBar {
                        Task {
                            await checkUserStatus()
                        }
                    }
                }
            })
    }
}

// MARK: - Completed Onboarding Previews

#Preview("✅ Completed - Tab Bar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.complete))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

// MARK: - Onboarding Step Previews

#Preview("1️⃣ Not Authenticated") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .previewEnvironment()
}

#Preview("2️⃣ Loading User Data") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil, delay: 3)))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("3️⃣ Subscription Step") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.subscription))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("4️⃣ Complete Account Setup") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.completeAccountSetup))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("5️⃣ Health Disclaimer") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.healthDisclaimer))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("6️⃣ Goal Setting") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.goalSetting))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("7️⃣ Customise Program") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.customiseProgram))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("8️⃣ Diet Plan") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.diet))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

// MARK: - Error State Previews

#Preview("❌ Auth Failure") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil, showError: true)))
        .environment(AuthManager(service: MockAuthService(user: nil, showError: true)))
        .previewEnvironment()
}

#Preview("❌ User Load Failure") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil, showError: true)))
        .environment(AuthManager(service: MockAuthService(user: .mock(), showError: true)))
        .previewEnvironment()
}

extension AppView {
    private func schedulePushNotifications() {
        pushManager.schedulePushNotificationsForNextWeek()
    }

    private func showATTPromptIfNeeded() async {
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        logManager.trackEvent(event: Event.attStatus(dict: status.eventParameters))
    }
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            // User is authenticated
            logManager.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await userManager.logIn(auth: user)
            } catch {
                logManager.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            // User is not authenticated
            logManager.trackEvent(event: Event.anonAuthStart)
            do {
                _ = try await authManager.signInAnonymously()

                // Log in to app
                logManager.trackEvent(event: Event.anonAuthSuccess)
//                
//                // Log in
//                try await userManager.logIn(auth: result)
                
            } catch {
                logManager.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }

    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthSuccess
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        case attStatus(dict: [String: Any])

        var eventName: String {
            switch self {
            case .existingAuthStart: return "AppView_ExistingAuth_Start"
            case .existingAuthSuccess: return "AppView_ExistingAuth_Success"
            case .existingAuthFail:  return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:     return "AppView_AnonAuth_Start"
            case .anonAuthSuccess:   return "AppView_AnonAuth_Success"
            case .anonAuthFail:      return "AppView_AnonAuth_Fail"
            case .attStatus:         return "AppView_ATTStatus"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            case .attStatus(dict: let dict):
                return dict
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}
