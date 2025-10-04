//
//  OnboardingFlow.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/10/2025.
//

import SwiftUI

struct OnboardingFlow: View {
    @Environment(UserManager.self) private var userManager
    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(PushManager.self) private var pushManager
    @Environment(AppState.self) private var appState
    @State var step: OnboardingEntry = .welcome
    var body: some View {
        switch step {
        case .welcome:
            OnboardingWelcomeView()
        case .auth:
            AuthOptionsSection()
        case .notifications:
            OnboardingNotificationsView()
        case .health:
            OnboardingHealthDataView()
        case .completed:
            OnboardingCompletedView()
        }
    }

    private func routeForCurrentUser() async {
        // Default to onboarding welcome until we confirm otherwise
        appState.updateViewState(showTabBarView: false)
        step = .welcome

        guard let user = userManager.currentUser else { return }

        // If user finished onboarding previously, still gate on permissions
        if user.didCompleteOnboarding == true {
            let needsPush = await pushManager.canRequestAuthorisation()
            let needsHealth = healthKitManager.needsAuthorizationForRequiredTypes()

            if needsPush {
                step = .notifications
                appState.updateViewState(showTabBarView: false)
            } else if needsHealth {
                step = .health
                appState.updateViewState(showTabBarView: false)
            } else {
                appState.updateViewState(showTabBarView: true)
            }
            return
        }

        // User has not completed onboarding yet → start at welcome
        step = .welcome
    }

    enum OnboardingEntry {
        case welcome
        case auth
        case notifications
        case health
        case completed
    }
}

#Preview("Welcome") {
    OnboardingFlow()
        .previewEnvironment()
}

#Preview("Auth - New user") {
    OnboardingFlow()
        .previewEnvironment()
}

#Preview("Auth - Existing user") {
    OnboardingFlow()
        .previewEnvironment()
}

#Preview("Notifications") {
    OnboardingFlow()
        .previewEnvironment()
}

#Preview("Health") {
    OnboardingFlow()
        .previewEnvironment()
}

#Preview("Completed") {
    OnboardingFlow()
        .previewEnvironment()
}
