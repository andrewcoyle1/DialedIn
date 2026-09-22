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

    /// The dates the picker offers. Nobody was born tomorrow, and an unbounded picker let them be:
    /// a future birth date gives a negative age, which the expenditure step then feeds straight
    /// into the Mifflin-St Jeor equation. The far end reaches back a century so that a genuinely
    /// old user is not pushed forward onto a birth date that is not theirs.
    var dateRange: ClosedRange<Date> {
        let now = Date()
        let earliest = Calendar.current.date(byAdding: .year, value: -120, to: now) ?? now
        return earliest...now
    }
    
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
            case .navigate: return "DateOfBirthView_Navigate"
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
