//
//  CalendarPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/01/2026.
//

import SwiftUI

@Observable
@MainActor
class CalendarPresenter {

    private let interactor: CalendarInteractor
    private let router: CalendarRouter

    private(set) var currentMonth: Date = Date.now
    private(set) var selectedDate: Date = Date.now
    private(set) var selectedHour: Date = Date.now
    private(set) var days: [Date] = []

    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    init(interactor: CalendarInteractor, router: CalendarRouter) {
        self.interactor = interactor
        self.router = router
        updateDays()
    }

    func onBackMonthPressed() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
        updateDays()
    }

    func onForwardMonthPressed() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
        updateDays()
    }

    func onDateSelected(day: Date, do onDateSelected: (Date, Date) -> Void) {
        selectedDate = day
        onDateSelected(day, selectedHour)
        router.dismissScreen()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    private func updateDays() {
        days = currentMonth.calendarDisplayDays
    }

    func foregroundStyle(for day: Date) -> Color {
        let isDifferentMonth = day.monthInt != currentMonth.monthInt
        let isSelectedDate = day.formattedDate == selectedDate.formattedDate
        let isPastDate = day < Date.now.startOfDay

        if isDifferentMonth {
            return .secondary
        } else if isPastDate {
            return .secondary
        } else if isSelectedDate {
            return .white
        } else {
            return .primary
        }
    }

}
