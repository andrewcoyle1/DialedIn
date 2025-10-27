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
}

// MARK: - Onboarding Step Previews

#Preview("1️⃣ Not Authenticated") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
}

#Preview("2️⃣ Loading User Data") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
}

#Preview("3️⃣ Subscription Step") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
}

#Preview("4️⃣ Complete Account Setup") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
}

#Preview("5️⃣ Health Disclaimer") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
}

#Preview("6️⃣ Goal Setting") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
}

#Preview("7️⃣ Customise Program") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
}

#Preview("8️⃣ Diet Plan") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
}

// MARK: - Error State Previews

#Preview("❌ Auth Failure") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
}

#Preview("❌ User Load Failure") {
    AppView(viewModel: AppViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)), appState: AppState(showTabBar: false))
}
