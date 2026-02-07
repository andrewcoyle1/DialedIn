//
//  ExpenditurePresenter.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@Observable
@MainActor
class ExpenditurePresenter {

    private let interactor: ExpenditureInteractor
    private let router: ExpenditureRouter
    private let calendar = Calendar.current

    private(set) var cachedEntries: [ExpenditureEntry] = []
    private(set) var cachedTimeSeries: [TimeSeriesData.TimeSeries] = []

    init(interactor: ExpenditureInteractor, router: ExpenditureRouter) {
        self.interactor = interactor
        self.router = router
        rebuildCaches()
    }

    func loadData() {
        rebuildCaches()
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    private func rebuildCaches() {
        let tdee = interactor.estimateTDEE(user: interactor.currentUser)
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startDate = calendar.date(byAdding: .day, value: -89, to: startOfToday) else {
            cachedEntries = []
            cachedTimeSeries = []
            return
        }

        var entries: [ExpenditureEntry] = []
        var data: [TimeSeriesDatapoint] = []

        for offset in 0..<90 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else { continue }
            let dayKey = date.dayKey
            entries.append(ExpenditureEntry(id: dayKey, date: date, expenditure: tdee))
            data.append(TimeSeriesDatapoint(id: dayKey, date: date, value: tdee))
        }

        cachedEntries = entries.reversed()
        cachedTimeSeries = [
            TimeSeriesData.TimeSeries(name: "Expenditure", data: data)
        ]
    }
}

extension ExpenditurePresenter: @MainActor MetricDetailPresenter {
    typealias Entry = ExpenditureEntry

    var entries: [ExpenditureEntry] {
        cachedEntries
    }

    var timeSeries: [TimeSeriesData.TimeSeries] {
        cachedTimeSeries
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Expenditure",
            analyticsName: "ExpenditureView",
            yAxisSuffix: "",
            seriesNames: ["Expenditure"],
            showsAddButton: false,
            sectionHeader: "Daily Expenditure",
            emptyStateMessage: "No expenditure data",
            pageSize: 20,
            chartType: .line
        )
    }

    func onAppear() async {
        loadData()
    }

    func onAddPressed() {
        // No-op: expenditure is derived from user profile
    }

    func onDeleteEntry(_ entry: ExpenditureEntry) async {
        // No-op: expenditure is derived from user profile
    }
}
