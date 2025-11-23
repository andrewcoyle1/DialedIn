//
//  ProfileHeaderViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfileHeaderInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfileHeaderInteractor { }

@MainActor
protocol ProfileHeaderRouter {
    func showProfileEditView()
    func showDevSettingsView()
}

extension CoreRouter: ProfileHeaderRouter { }

@Observable
@MainActor
class ProfileHeaderViewModel {
    private let interactor: ProfileHeaderInteractor
    private let router: ProfileHeaderRouter

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: ProfileHeaderInteractor,
        router: ProfileHeaderRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func navToProfileEdit() {
        interactor.trackEvent(event: Event.navigate)
        router.showProfileEditView()
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "ProfileHeader_Navigate"
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
