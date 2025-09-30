//
//  AppView.swift
//  BrainBolt
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI
@preconcurrency import FirebaseFunctions

struct AppView: View {

    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @State var appState: AppState = AppState()

    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabBarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
        .environment(appState)
        .task {
            await checkUserStatus()
        }
        .onChange(of: appState.showTabBar) { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
        .onChange(of: userManager.currentUser) { _, user in
            // If an existing user has already completed onboarding on this or another device,
            // immediately transition to the main app.
            if user?.didCompleteOnboarding == true {
                appState.updateViewState(showTabBarView: true)
            }
        }
        #if !MOCK
        .task {
            await getDataFromMyNewEndpoint()
        }
        #endif
    }
    
    #if !MOCK
    private func getDataFromMyNewEndpoint() async {
        logManager.trackEvent(eventName: "HELLODEV:: START", type: .info)

        do {
            let result = try await Functions.functions().httpsCallable("helloDeveloper").call()
            let string = result.data as? String
            
            logManager.trackEvent(eventName: "HELLODEV:: \(string ?? "nostring")", type: .info)
            
        } catch {
            logManager.trackEvent(eventName: "HELLODEV:: ERROR \(error.localizedDescription)", type: .info)

        }
    }
    #endif
    
    enum Event: LoggableEvent {
        case existingAuthStart
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        
        var eventName: String {
            switch self {
            case .existingAuthStart: return "AppView_ExistingAuth_Start"
            case .existingAuthFail:  return "AppView_ExistingAuth_Fail"
            case .anonAuthStart:     return "AppView_AnonAuth_Start"
            case .anonAuthSuccess:   return "AppView_AnonAuth_Success"
            case .anonAuthFail:      return "AppView_AnonAuth_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
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
    
    private func checkUserStatus() async {
        if let user = authManager.auth {
            // User is authenticated
            logManager.trackEvent(event: Event.existingAuthStart)
            
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                logManager.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        } else {
            // User is not authenticated
            logManager.trackEvent(event: Event.anonAuthStart)
            do {
                let result = try await authManager.signInAnonymously()
                
                // log in to app
                logManager.trackEvent(event: Event.anonAuthSuccess)

                // Log in
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                
            } catch {
                logManager.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

#Preview("Onboarding - Functioning") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .previewEnvironment()
}

#Preview("Onboarding Slow Loading") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil, delay: 3)))
        .environment(AuthManager(service: MockAuthService(user: nil, delay: 3)))
        .previewEnvironment()
}

#Preview("Onboarding Auth Failure") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil, showError: true)))
        .environment(AuthManager(service: MockAuthService(user: nil, showError: true)))
        .previewEnvironment()
}

#Preview("Onboarding User Failure") {
    AppView(appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil, showError: true)))
        .environment(AuthManager(service: MockAuthService(user: .mock(), showError: true)))
        .previewEnvironment()
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()

}
