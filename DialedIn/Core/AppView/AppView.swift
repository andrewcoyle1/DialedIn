//
//  AppView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct AppView<AdaptiveMainView: View, OnboardingView: View>: View {

    @State var presenter: AppPresenter

    @ViewBuilder var adaptiveMainView: () -> AdaptiveMainView
    @ViewBuilder var onboardingWelcomeView: () -> OnboardingView

    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await presenter.checkUserStatus()
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
                        presenter.showTabBar,
                    tabBarView: {
                        adaptiveMainView()
                    },
                    onboardingView: {
                        onboardingWelcomeView()
                    }
                )
                .onFirstAppear {
                    presenter.schedulePushNotifications()
                }
                .task {
                    await presenter.checkUserStatus()
                    try? await Task.sleep(for: .seconds(2))
                    await presenter.showATTPromptIfNeeded()
                }
            }
        )
    }
}

// MARK: - Completed Onboarding Previews

#Preview("✅ Completed - Tab Bar") {
    let container = DevPreview.shared.container
    container.register(AppState.self, service: AppState(showTabBar: true))

    let builder = RootBuilder(
        interactor: RootInteractor(container: container),
        loggedInRIB: CoreBuilder(interactor: CoreInteractor(container: container)),
        loggedOutRIB: OnbBuilder(interactor: OnbInteractor(container: container))
    )
    return builder.build()
    .previewEnvironment()
}

// MARK: - Onboarding Step Previews

#Preview("1️⃣ Not Authenticated") {
    let container = DevPreview.shared.container
    container.register(UserManager.self, service: UserManager(services: MockUserServices(user: nil)))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: nil)))
    container.register(AppState.self, service: AppState(showTabBar: false))

    let builder = RootBuilder(
        interactor: RootInteractor(container: container),
        loggedInRIB: CoreBuilder(interactor: CoreInteractor(container: container)),
        loggedOutRIB: OnbBuilder(interactor: OnbInteractor(container: container))
    )
    return builder.build()
    .previewEnvironment()
}
