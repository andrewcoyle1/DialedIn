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

@Observable
@MainActor
class ProfileHeaderViewModel {
    private let interactor: ProfileHeaderInteractor

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(interactor: ProfileHeaderInteractor) {
        self.interactor = interactor
    }

    func navToProfileEdit(path: Binding<[TabBarPathOption]>) {
        interactor.trackEvent(event: Event.navigate(destination: .profileEdit))
        path.wrappedValue.append(.profileEdit)
    }

    enum Event: LoggableEvent {
        case navigate(destination: TabBarPathOption)

        var eventName: String {
            switch self {
            case .navigate: return "ProfileHeader_Navigate"
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
