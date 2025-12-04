//
//  ProfilePresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfilePresenter {
    private let interactor: ProfileInteractor
    private let router: ProfileRouter

    private(set) var activeGoal: WeightGoal?

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var currentGoal: WeightGoal? {
        interactor.currentGoal
    }
    
    var currentDietPlan: DietPlan? {
        interactor.currentDietPlan
    }
    
    init(
        interactor: ProfileInteractor,
        router: ProfileRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func getActiveGoal() async {
        if let userId = self.currentUser?.userId {
            activeGoal = try? await interactor.getActiveGoal(userId: userId)
        }
    }

    func navToSettingsView() {
        interactor.trackEvent(event: Event.navigate)
        router.showSettingsView()
    }

    func onNotificationsPressed() {
        router.showNotificationsView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func onCreateAccountPressed() {
        router.showCreateAccountView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate:     return "Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
        }
    }
}
