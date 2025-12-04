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
    private let appState: AppState
    private let pushManager: PushManager
    private let logManager: LogManager
    private let trainingPlanManager: TrainingPlanManager

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
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
    
    func logIn(auth: UserAuthInfo, image: PlatformImage?) async throws {
        try await userManager.logIn(auth: auth, image: image)
        
        // Start the sync listener for training plans
        let userId = try userManager.currentUserId()
        trainingPlanManager.startSyncListener(userId: userId)
    }
    
}
