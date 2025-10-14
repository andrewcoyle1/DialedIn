//
//  OnboardingRouterView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/10/2025.
//

import SwiftUI

struct OnboardingRouterView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    
    var body: some View {
        Group {
            // Default to WelcomeView if not authenticated or is anonymous
            if let auth = authManager.auth, !auth.isAnonymous {
                // User is authenticated (not anonymous), check onboarding step
                if let currentUser = userManager.currentUser {
                    routeToOnboardingStep(currentUser.onboardingStep)
                } else {
                    // User is authenticated but no user model yet, show loading
                    loadingView
                }
            } else {
                // User is not authenticated or is anonymous, show WelcomeView
                OnboardingWelcomeView()
            }
        }
    }
    
    @ViewBuilder
    private func routeToOnboardingStep(_ step: OnboardingStep?) -> some View {
        NavigationStack {
            switch step {
            case .auth, nil:
                // User hasn't completed auth step or step is nil
                OnboardingWelcomeView()
            case .subscription:
                OnboardingSubscriptionView()
            case .completeAccountSetup:
                OnboardingCompleteAccountSetupView()
            case .healthDisclaimer:
                OnboardingHealthDisclaimerView()
            case .goalSetting:
                OnboardingGoalSettingView()
            case .customiseProgram:
                OnboardingCustomisingProgramView()
            case .diet:
                OnboardingDietPlanView()
            case .complete:
                OnboardingCompletedView()
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
    OnboardingRouterView()
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .previewEnvironment()
}

#Preview("Anonymous User") {
    OnboardingRouterView()
        .environment(UserManager(services: MockUserServices(user: nil)))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
        .previewEnvironment()
}

#Preview("Subscription Step") {
    OnboardingRouterView()
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.subscription))))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: false))))
        .previewEnvironment()
}

#Preview("Complete Account Setup Step") {
    OnboardingRouterView()
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.completeAccountSetup))))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: false))))
        .previewEnvironment()
}

#Preview("Health Disclaimer Step") {
    OnboardingRouterView()
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.healthDisclaimer))))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: false))))
        .previewEnvironment()
}

#Preview("Goal Setting Step") {
    OnboardingRouterView()
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.goalSetting))))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: false))))
        .previewEnvironment()
}

#Preview("Customise Program Step") {
    OnboardingRouterView()
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.customiseProgram))))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: false))))
        .previewEnvironment()
}

#Preview("Diet Step") {
    OnboardingRouterView()
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.diet))))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: false))))
        .previewEnvironment()
}

#Preview("Complete Step") {
    OnboardingRouterView()
        .environment(UserManager(services: MockUserServices(user: .mockWithStep(.complete))))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: false))))
        .previewEnvironment()
}
