//
//  RootInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/12/2025.
//

import SwiftUI

struct RootInteractor {
    private let authManager: AuthManager
    private let userManager: UserManager
    private let abTestManager: ABTestManager
    private let purchaseManager: PurchaseManager
    private let appState: AppState
    private let pushManager: PushManager
    private let logManager: LogManager
    private let trainingPlanManager: TrainingPlanManager

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.appState = container.resolve(AppState.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
    }
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    var showTabBar: Bool {
        appState.showTabBar
    }
    
    func schedulePushNotificationsForNextWeek() {
        pushManager.schedulePushNotificationsForNextWeek()
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func logIn(user: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.logIn(auth: user, isNewUser: isNewUser)
        try await purchaseManager.logIn(
            userId: user.uid,
            userAttributes: PurchaseProfileAttributes(
                email: user.email,
                mixpanelDistinctId: Constants.mixpanelDistinctId,
                firebaseAppInstanceId: Constants.firebaseAnalyticsAppInstanceID
            )
        )
    }

}
