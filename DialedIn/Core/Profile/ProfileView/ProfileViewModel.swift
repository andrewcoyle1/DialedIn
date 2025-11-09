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

@Observable
@MainActor
class ProfileViewModel {
    private let interactor: ProfileInteractor
    
    private(set) var activeGoal: WeightGoal?
    
#if DEBUG || MOCK
    var showDebugView: Bool = false
#endif
    var showNotifications: Bool = false
    var showCreateProfileSheet: Bool = false
    var showSetGoalSheet: Bool = false
    
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
        interactor: ProfileInteractor
    ) {
        self.interactor = interactor
    }
    
    func getActiveGoal() async {
        if let userId = self.currentUser?.userId {
            activeGoal = try? await interactor.getActiveGoal(userId: userId)
        }
    }

    func navToSettingsView(path: Binding<[TabBarPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .settingsView))
        path.wrappedValue.append(.settingsView)
    }

    enum Event: LoggableEvent {
        case navigate(destination: TabBarPathOption)

        var eventName: String {
            switch self {
            case .navigate:     return "Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate(destination: let destination):
                return destination.eventParameters
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
