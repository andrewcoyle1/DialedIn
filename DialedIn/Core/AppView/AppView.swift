//
//  AppView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct AppView: View {

    @Environment(CoreBuilder.self) private var builder
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: AppViewModel

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
                        builder.adaptiveMainView()
                    },
                    onboardingView: {
                        OnboardingWelcomeView(
                            viewModel: OnboardingWelcomeViewModel(
                                interactor: CoreInteractor(
                                    container: container
                                )
                            )
                        )
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

    return AppView(
        viewModel: AppViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        )
    )
    .previewEnvironment()
}

// MARK: - Onboarding Step Previews

#Preview("1️⃣ Not Authenticated") {
    let container = DevPreview.shared.container
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(AppState.self, service: AppState(showTabBar: false))

    return AppView(
        viewModel: AppViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        )
    )
    .previewEnvironment()
}
