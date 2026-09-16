import SwiftUI

@Observable
@MainActor
class CalendarHeaderPresenter {
    
    private let interactor: CalendarHeaderInteractor
    private let router: CalendarHeaderRouter
    private let delegate: CalendarHeaderDelegate

    let calendar = Calendar.current

    var selectedDate: Date = Date()

    /// Refreshed on `NSCalendarDayChanged`; as a value captured at init, a session left open
    /// past midnight kept highlighting yesterday.
    private(set) var today: Date = Calendar.current.startOfDay(for: .now)

    /// Held between the day being picked in the expanded calendar and that sheet finishing its
    /// dismissal, when the host screen's action can safely run.
    private var dateAwaitingHostAction: Date?

    private let startDate: Date
    private let endDate: Date
    private let daysPerLoad: Int = 100

    /// One page of the header. Identified by its start date so the `ForEach` identity and
    /// `scrollPosition(id:)` are the same `Date` — previously the rows were identified by the
    /// whole `[Date]` array and carried a second, separate `.id()` for the scroll target.
    struct Week: Identifiable, Hashable {
        let id: Date
        let days: [Date]
    }

    /// Cached because the view reads this while scrolling. As a computed property it rebuilt
    /// 29 weeks on every body pass, which showed up as stutter in the header.
    private(set) var weeks: [Week] = []

    init(interactor: CalendarHeaderInteractor, router: CalendarHeaderRouter, delegate: CalendarHeaderDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate

        // Initialize with a large range centered on today
        let today = calendar.startOfDay(for: Date())
        self.startDate = calendar.date(byAdding: .day, value: -daysPerLoad, to: today) ?? today
        self.endDate = calendar.date(byAdding: .day, value: daysPerLoad, to: today) ?? today
        
        self.weeks = computedWeeks
    }

    /// The week containing today, for the view's initial scroll position.
    var currentWeekStart: Date {
        weekStart(for: .now)
    }

    /// The page the strip has to scroll to in order to show `date`.
    func weekStart(for date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
    }

    func refreshToday() {
        today = calendar.startOfDay(for: .now)
    }

    private var computedWeeks: [Week] {
        guard
            let firstWeekStart = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start,
            let lastWeekStart = calendar.dateInterval(of: .weekOfYear, for: endDate)?.start
        else {
            return []
        }

        var result: [Week] = []
        var weekStart = calendar.startOfDay(for: firstWeekStart)
        let finalWeekStart = calendar.startOfDay(for: lastWeekStart)

        while weekStart <= finalWeekStart {
            var week: [Date] = []
            for dayOffset in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                    week.append(calendar.startOfDay(for: day))
                }
            }
            result.append(Week(id: weekStart, days: week))

            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart) else {
                break
            }
            weekStart = calendar.startOfDay(for: nextWeek)
        }

        return result
    }

    func onDatePressed(_ date: Date) {
        selectedDate = date
        delegate.onDatePressed(date)
    }

    /// `onDismiss` lets the view clear the binding the parent's toolbar button set, so the
    /// button works again on the next press.
    func showLargeCalendar(
        _ transitionId: String,
        in namespace: Namespace.ID,
        onDismiss: @escaping () -> Void = { }
    ) {
        interactor.trackEvent(event: Event.openLargeCalendar)
        router.showCalendarViewZoom(
            delegate: CalendarDelegate(
                selectedDate: selectedDate,
                // The strip follows the selection right away, behind the dismissing sheet. The
                // host action waits for `onDidDismiss` below: Training's opens a session detail
                // screen through its own router, and the router sweeps away anything presented
                // before its dismissal clean-up has run.
                onDateSelected: { [weak self] date, _ in
                    guard let self else { return }
                    self.interactor.trackEvent(event: Event.datePickedFromCalendar)
                    self.selectedDate = date
                    self.dateAwaitingHostAction = date
                },
                activityCountsByDay: delegate.activityCountsByDay
            ),
            onDismiss: onDismiss,
            onDidDismiss: { [weak self] in
                guard let self, let date = self.dateAwaitingHostAction else { return }
                self.dateAwaitingHostAction = nil
                self.delegate.onDatePressed(date)
            },
            transitionId: transitionId,
            namespace: namespace
        )
    }

    /// One map for the whole header rather than a lookup per cell. Each `getForDate` call used
    /// to filter every session or meal, so a single body pass ran seven full scans.
    func activityCountsByDay() -> [Date: Int] {
        delegate.activityCountsByDay()
    }

    enum Event: LoggableEvent {
        case openLargeCalendar
        case datePickedFromCalendar
        case dateSelectionFunctionTriggered

        var eventName: String {
            switch self {
            case .openLargeCalendar:                return "CalendarHeader_OpenLargeCalendar"
            case .datePickedFromCalendar:           return "CalendarHeader_DatePickedFromLargeCalendar"
            case .dateSelectionFunctionTriggered:   return "CalendarHeader_DateSelectionFunction_Triggered"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            default:
                return .info
            }
        }
    }

}
