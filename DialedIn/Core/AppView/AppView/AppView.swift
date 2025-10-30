//
//  AppView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct AppView: View {
    @Environment(DependencyContainer.self) private var container
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
            ),
            content: {
                AppViewBuilder(
                    showTabBar: {
                        if let auth = viewModel.auth,
                           !auth.isAnonymous,
                           viewModel.currentUser?.onboardingStep == .complete {
                            return true
                        }
                        return false
                    }(),
                    tabBarView: {
                        AdaptiveMainView(
                            viewModel: AdaptiveMainViewModel(
                                interactor: CoreInteractor(
                                    container: container
                                )
                            )
                        )
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
                .environment(appState)
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
    AppView(
        viewModel: AppViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        ),
        appState: AppState(
            showTabBar: true
        )
    )
}

// MARK: - Onboarding Step Previews

#Preview("1️⃣ Not Authenticated") {
    AppView(
        viewModel: AppViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        ),
        appState: AppState(
            showTabBar: false
        )
    )
}
