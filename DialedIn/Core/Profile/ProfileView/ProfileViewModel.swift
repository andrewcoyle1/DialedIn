//
//  ProfileViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfileInteractor {
    var currentUser: UserModel? { get }
    var currentGoal: WeightGoal? { get }
    var currentDietPlan: DietPlan? { get }
    func getActiveGoal(userId: String) async throws -> WeightGoal?
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfileInteractor { }

@MainActor
protocol ProfileRouter {
    func showNotificationsView()
    func showDevSettingsView()
    func showCreateAccountView()
    func showSettingsView()
    func showSetGoalFlowView()
}

extension CoreRouter: ProfileRouter { }

@Observable
@MainActor
class ProfileViewModel {
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

    func onSetGoalPressed() {
        router.showSetGoalFlowView()
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
