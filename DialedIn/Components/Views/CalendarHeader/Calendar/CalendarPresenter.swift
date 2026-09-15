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
    private let delegate: CalendarDelegate

    private(set) var currentMonth: Date = Date.now
    private(set) var selectedDate: Date = Date.now
    private(set) var selectedHour: Date = Date.now
    private(set) var days: [Date] = []

    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)

    init(
        interactor: CalendarInteractor,
        router: CalendarRouter,
        delegate: CalendarDelegate
    ) {
        self.interactor = interactor
        self.router = router
        self.delegate = delegate

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

    func onTodayPressed() {
        currentMonth = Date.now
        updateDays()
    }

    func onDateSelected(day: Date) {
        guard isSelectable(day) else { return }

        selectedDate = day

        router.dismissScreen()

        delegate.onDateSelected(day, selectedHour)
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    private func updateDays() {
        days = currentMonth.calendarDisplayDays
    }

    var isViewingCurrentMonth: Bool {
        Calendar.current.isDate(currentMonth, equalTo: Date.now, toGranularity: .month)
    }

    /// Only the leading/trailing filler days of the adjacent months are unselectable.
    /// Past dates used to be disabled too, which made the sheet unusable for its one
    /// purpose — the header it opens from navigates Training and Nutrition to a past day.
    func isSelectable(_ day: Date) -> Bool {
        day.monthInt == currentMonth.monthInt
    }

    func isSelected(_ day: Date) -> Bool {
        isSelectable(day) && day.formattedDate == selectedDate.formattedDate
    }

    func isToday(_ day: Date) -> Bool {
        isSelectable(day) && Calendar.current.isDateInToday(day)
    }

    func foregroundStyle(for day: Date) -> Color {
        if !isSelectable(day) {
            return .secondary.opacity(0.5)
        } else if isSelected(day) {
            return .white
        } else if isToday(day) {
            return .accentColor
        } else {
            return .primary
        }
    }

}
