import SwiftUI

@Observable
@MainActor
class CalendarHeaderPresenter {
    
    private let interactor: CalendarHeaderInteractor
    private let router: CalendarHeaderRouter
    private let delegate: CalendarHeaderDelegate

    let calendar = Calendar.current

    var selectedDate: Date = Date()
    var selectedTime: Date = Date()
    
    var today: Date = Date()
    var weekScrollPosition: Date?
    var hasScrolledToToday = false
    private var pendingSelectedDateFromLargeCalendar: Date?

    // Date range for infinite scrolling
    private var startDate: Date
    private var endDate: Date
    private let daysPerLoad: Int = 100

    init(interactor: CalendarHeaderInteractor, router: CalendarHeaderRouter, delegate: CalendarHeaderDelegate) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate

        // Initialize with a large range centered on today
        let today = calendar.startOfDay(for: Date())
        self.startDate = calendar.date(byAdding: .day, value: -daysPerLoad, to: today) ?? today
        self.endDate = calendar.date(byAdding: .day, value: daysPerLoad, to: today) ?? today
        
        let now = Date()
        let weekStart = Calendar.current.dateInterval(of: .weekOfYear, for: now)?.start
            ?? Calendar.current.startOfDay(for: now)
        self.weekScrollPosition = weekStart
    }
    
    var days: [Date] {
        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: startDate)
        let normalizedEndDate = calendar.startOfDay(for: endDate)
        
        while currentDate <= normalizedEndDate {
            dates.append(currentDate)
            if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        return dates
    }

    var weeks: [[Date]] {
        guard
            let firstWeekStart = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start,
            let lastWeekStart = calendar.dateInterval(of: .weekOfYear, for: endDate)?.start
        else {
            return []
        }

        var result: [[Date]] = []
        var weekStart = calendar.startOfDay(for: firstWeekStart)
        let finalWeekStart = calendar.startOfDay(for: lastWeekStart)

        while weekStart <= finalWeekStart {
            var week: [Date] = []
            for dayOffset in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                    week.append(calendar.startOfDay(for: day))
                }
            }
            result.append(week)

            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart) else {
                break
            }
            weekStart = calendar.startOfDay(for: nextWeek)
        }

        return result
    }

    func onDatePressed(_ date: Date) {
        delegate.onDatePressed(date)
    }

    func showLargeCalendar(_ transitionId: String, in namespace: Namespace.ID) {
        interactor.trackEvent(event: Event.openLargeCalendar)
        router.showCalendarViewZoom(
            delegate: CalendarDelegate(
                onDateSelected: { date, _ in
                    self.selectedDate = date
                    self.pendingSelectedDateFromLargeCalendar = date
                }
            ),
            onDismiss: { [weak self] in
                guard let self, let selectedDate = self.pendingSelectedDateFromLargeCalendar else { return }
                self.pendingSelectedDateFromLargeCalendar = nil
                self.onDatePressed(selectedDate)
            },
            transitionId: transitionId,
            namespace: namespace
        )
    }

    func getForDate(_ date: Date) -> Int {
        delegate.getForDate(date)
    }

    func loadMoreDatesIfNeeded(visibleStartIndex: Int, visibleEndIndex: Int) {
        let totalDays = days.count
        let threshold = 20 // Load more when within 20 days of edge
        
        // Load more dates before start
        if visibleStartIndex < threshold {
            if let newStartDate = calendar.date(byAdding: .day, value: -daysPerLoad, to: startDate) {
                startDate = calendar.startOfDay(for: newStartDate)
            }
        }
        
        // Load more dates after end
        if visibleEndIndex > totalDays - threshold {
            if let newEndDate = calendar.date(byAdding: .day, value: daysPerLoad, to: endDate) {
                endDate = calendar.startOfDay(for: newEndDate)
            }
        }
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
