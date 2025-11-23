//
//  OnboardingGoalSettingViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

protocol OnboardingGoalSettingInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: OnboardingGoalSettingInteractor { }

@MainActor
protocol OnboardingGoalSettingRouter {
    func showDevSettingsView()
    func showOnboardingOverarchingObjectiveView()
}

extension CoreRouter: OnboardingGoalSettingRouter { }

@Observable
@MainActor
class OnboardingGoalSettingViewModel {
    private let interactor: OnboardingGoalSettingInteractor
    private let router: OnboardingGoalSettingRouter

    var showAlert: AnyAppAlert?
    var isLoading: Bool = false
    
    init(
        interactor: OnboardingGoalSettingInteractor,
        router: OnboardingGoalSettingRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func navigateToOverarchingObjective() {
        interactor.trackEvent(event: Event.navigate)
        router.showOnboardingOverarchingObjectiveView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "GoalSetting_Navigate"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            default: return nil
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
