//
//  AppView.swift
//  BrainBolt
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI
// @preconcurrency import FirebaseFunctions

struct AppView: View {
    @State var viewModel: AppViewModel
    @State var appState: AppState = AppState()
        
    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await viewModel.checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil
            ), content: {
                AppViewBuilder(
                    showTabBar: {
                        if let auth = viewModel.auth, !auth.isAnonymous,
                           viewModel.currentUser?.onboardingStep == .complete {
                            return true
                        }
                        return false
                    }(),
                    tabBarView: {
                        AdaptiveMainView()
                    },
                    onboardingView: {
                        OnboardingRouterView()
                    }
                )
                .environment(appState)
                .task {
                    await viewModel.checkUserStatus()
                }
                .task {
                    try? await Task.sleep(for: .seconds(2))
                    await viewModel.showATTPromptIfNeeded()
                }
                .onFirstAppear {
                    viewModel.schedulePushNotifications()
                }
            })
    }
}

// MARK: - Completed Onboarding Previews

#Preview("✅ Completed - Tab Bar") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: true))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.complete))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

// MARK: - Onboarding Step Previews

#Preview("1️⃣ Not Authenticated") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .previewEnvironment()
}

#Preview("2️⃣ Loading User Data") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil, delay: 3)))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("3️⃣ Subscription Step") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.subscription))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("4️⃣ Complete Account Setup") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.completeAccountSetup))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("5️⃣ Health Disclaimer") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.healthDisclaimer))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("6️⃣ Goal Setting") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.goalSetting))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("7️⃣ Customise Program") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.customiseProgram))))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvironment()
}

#Preview("8️⃣ Diet Plan") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
        .previewEnvironment()
}

// MARK: - Error State Previews

#Preview("❌ Auth Failure") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil, showError: true)))
        .environment(AuthManager(service: MockAuthService(user: nil, showError: true)))
        .previewEnvironment()
}

#Preview("❌ User Load Failure") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
        .environment(UserManager(services: MockUserServices(user: nil, showError: true)))
        .environment(AuthManager(service: MockAuthService(user: .mock(), showError: true)))
        .previewEnvironment()
}
