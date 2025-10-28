//
//  OnboardingRouterView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/10/2025.
//

import SwiftUI

struct OnboardingRouterView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingRouterViewModel

    var body: some View {
        Group {
            // Default to WelcomeView if not authenticated or is anonymous
            if let auth = viewModel.auth, !auth.isAnonymous {
                // User is authenticated (not anonymous), check onboarding step
                if let currentUser = viewModel.currentUser {
                    routeToOnboardingStep(currentUser.onboardingStep)
                } else {
                    // User is authenticated but no user model yet, show loading
                    loadingView
                }
            } else {
                // User is not authenticated or is anonymous, show WelcomeView
                OnboardingWelcomeView(
                    viewModel: OnboardingWelcomeViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
        }
    }
    // swiftlint:disable:next function_body_length
    @ViewBuilder private func routeToOnboardingStep(_ step: OnboardingStep?) -> some View {
        NavigationStack {
            switch step {
            case .auth, nil:
                // User hasn't completed auth step or step is nil
                OnboardingWelcomeView(
                    viewModel: OnboardingWelcomeViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            case .subscription:
                OnboardingSubscriptionView(
                    viewModel: OnboardingSubscriptionViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            case .completeAccountSetup:
                OnboardingCompleteAccountSetupView(viewModel: OnboardingCompleteAccountSetupViewModel(interactor: CoreInteractor(container: container)))
            case .healthDisclaimer:
                OnboardingHealthDisclaimerView(
                    viewModel: OnboardingHealthDisclaimerViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            case .goalSetting:
                OnboardingGoalSettingView(
                    viewModel: OnboardingGoalSettingViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            case .customiseProgram:
                OnboardingCustomisingProgramView(
                    viewModel: OnboardingCustomisingProgramViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            case .diet:
                OnboardingDietPlanView(
                    viewModel: OnboardingDietPlanViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            case .complete:
                OnboardingCompletedView(
                    viewModel: OnboardingCompletedViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading...")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.top)
        }
    }
}

// MARK: - Previews

#Preview("Not Authenticated") {
    OnboardingRouterView(
        viewModel: OnboardingRouterViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        )
    )
    .previewEnvironment()
}
