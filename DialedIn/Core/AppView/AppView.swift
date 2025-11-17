//
//  AppView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct AppView: View {

    @State var viewModel: AppViewModel

    @ViewBuilder var adaptiveMainView: () -> AnyView
    @ViewBuilder var onboardingWelcomeView: () -> AnyView

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
            ),
            content: {
                AppViewBuilder(
                    showTabBar:
                        viewModel.showTabBar,
                    tabBarView: {
                        adaptiveMainView()
                    },
                    onboardingView: {
                        onboardingWelcomeView()
                    }
                )
                .onFirstAppear {
                    viewModel.schedulePushNotifications()
                }
                .task {
                    await viewModel.checkUserStatus()
                    try? await Task.sleep(for: .seconds(2))
                    await viewModel.showATTPromptIfNeeded()
                }
            }
        )
    }
}

// MARK: - Completed Onboarding Previews

#Preview("✅ Completed - Tab Bar") {
    let container = DevPreview.shared.container
    container.register(AppState.self, service: AppState(showTabBar: true))

    let builder = CoreBuilder(container: container)
    return builder.appView()
    .previewEnvironment()
}

// MARK: - Onboarding Step Previews

#Preview("1️⃣ Not Authenticated") {
    let container = DevPreview.shared.container
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(AppState.self, service: AppState(showTabBar: false))

    let builder = CoreBuilder(container: container)
    return builder.appView()
    .previewEnvironment()
}
