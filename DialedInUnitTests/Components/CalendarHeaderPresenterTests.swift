//
//  CalendarHeaderPresenterTests.swift
//  DialedInUnitTests
//

import Testing
import Foundation
import SwiftUI
@testable import DialedIn

/// The calendar strip shared by Training and Nutrition.
///
/// `showCalendarViewZoom` needs a `Namespace.ID`, which cannot be made outside a view, so these
/// tests stay on the side of the presenter that does not present: picking a day in the strip.
@MainActor
struct CalendarHeaderPresenterTests {

    private final class Interactor: CalendarHeaderInteractor {
        private(set) var trackedEventNames: [String] = []

        func trackEvent(event: LoggableEvent) {
            trackedEventNames.append(event.eventName)
        }
    }

    private final class Router: CalendarHeaderRouter {
        func showCalendarViewZoom(
            delegate: CalendarDelegate,
            onDismiss: (() -> Void)?,
            onDidDismiss: (() -> Void)?,
            transitionId: String?,
            namespace: Namespace.ID
        ) { }
    }

    private final class Host {
        private(set) var pressedDates: [Date] = []

        func record(_ date: Date) { pressedDates.append(date) }
    }

    private struct Screen {
        let presenter: CalendarHeaderPresenter
        let interactor: Interactor
        let host: Host
    }

    private func makeScreen() -> Screen {
        let interactor = Interactor()
        let host = Host()
        let delegate = CalendarHeaderDelegate(
            onDatePressed: { host.record($0) },
            markersByDay: { [:] }
        )
        return Screen(
            presenter: CalendarHeaderPresenter(interactor: interactor, router: Router(), delegate: delegate),
            interactor: interactor,
            host: host
        )
    }

    private let day = Date(timeIntervalSince1970: 1_772_000_000)

    @Test("Test Pressing A Day Focuses It And Tells The Host")
    func testPressingADayFocusesItAndTellsTheHost() {
        let screen = makeScreen()

        screen.presenter.onDatePressed(day)

        #expect(screen.presenter.focusedDate == day)
        #expect(screen.host.pressedDates == [day])
    }

    /// Picking a day in the expanded calendar was tracked and returning to today was tracked, but
    /// the strip's own taps — by far the commonest way a day is chosen — were not.
    @Test("Test Pressing A Day In The Strip Is Tracked")
    func testPressingADayInTheStripIsTracked() {
        let screen = makeScreen()

        screen.presenter.onDatePressed(day)

        #expect(screen.interactor.trackedEventNames == ["CalendarHeader_DateSelectionFunction_Triggered"])
    }

    @Test("Test Returning To Today Is Tracked")
    func testReturningToTodayIsTracked() {
        let screen = makeScreen()

        screen.presenter.onReturnToTodayPressed()

        #expect(screen.interactor.trackedEventNames == ["CalendarHeader_ReturnedToToday"])
    }
}
