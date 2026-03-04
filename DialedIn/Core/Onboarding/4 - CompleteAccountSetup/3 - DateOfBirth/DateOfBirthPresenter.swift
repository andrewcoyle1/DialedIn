//
//  DateOfBirthPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import SwiftUI

@Observable
@MainActor
class DateOfBirthPresenter {
    private let interactor: DateOfBirthInteractor
    private let router: DateOfBirthRouter

    var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    
    init(
        interactor: DateOfBirthInteractor,
        router: DateOfBirthRouter
    ) {
        self.interactor = interactor
        self.router = router

    }
    
    func onContinuePressed(delegate: DateOfBirthDelegate) {
        let delegate = HeightDelegate(delegate: delegate, dateOfBirth: dateOfBirth)
        interactor.trackEvent(event: Event.navigate)
        router.showHeightView(delegate: delegate)
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate: return "GenderView_Navigate"
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
