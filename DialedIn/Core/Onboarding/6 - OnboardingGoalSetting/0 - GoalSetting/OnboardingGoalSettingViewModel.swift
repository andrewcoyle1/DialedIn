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

@Observable
@MainActor
class OnboardingGoalSettingViewModel {
    private let interactor: OnboardingGoalSettingInteractor
    
    var showAlert: AnyAppAlert?
    var isLoading: Bool = false
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(interactor: OnboardingGoalSettingInteractor) {
        self.interactor = interactor
    }
    
    func navigateToOverarchingObjective(path: Binding<[OnboardingPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .overarchingObjective))
        path.wrappedValue.append(.overarchingObjective)
    }
    
    enum Event: LoggableEvent {
        case navigate(destination: OnboardingPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "GoalSetting_Navigate"
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
