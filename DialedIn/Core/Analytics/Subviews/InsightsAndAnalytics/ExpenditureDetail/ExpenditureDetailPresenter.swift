//
//  ExpenditureDetailPresenter.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@Observable
@MainActor
class ExpenditureDetailPresenter {

    private let interactor: ExpenditureDetailInteractor
    private let router: ExpenditureDetailRouter
    private let calendar = Calendar.current

    private(set) var cachedEntries: [ExpenditureDetailEntry] = []
    private(set) var cachedTimeSeries: [TimeSeriesData.TimeSeries] = []

    init(interactor: ExpenditureDetailInteractor, router: ExpenditureDetailRouter) {
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

        var entries: [ExpenditureDetailEntry] = []
        var data: [TimeSeriesDatapoint] = []

        for offset in 0..<90 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else { continue }
            let dayKey = date.dayKey
            entries.append(ExpenditureDetailEntry(id: dayKey, date: date, expenditure: tdee))
            data.append(TimeSeriesDatapoint(id: dayKey, date: date, value: tdee))
        }

        cachedEntries = entries.reversed()
        cachedTimeSeries = [
            TimeSeriesData.TimeSeries(name: "ExpenditureDetail", data: data)
        ]
    }
}

extension ExpenditureDetailPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = ExpenditureDetailEntry

    var entries: [ExpenditureDetailEntry] {
        cachedEntries
    }

    var timeSeries: [TimeSeriesData.TimeSeries] {
        cachedTimeSeries
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "ExpenditureDetail",
            analyticsName: "ExpenditureDetailView",
            yAxisSuffix: "",
            seriesNames: ["ExpenditureDetail"],
            showsAddButton: false,
            sectionHeader: "Daily ExpenditureDetail",
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

    func onDeleteEntry(_ entry: ExpenditureDetailEntry) async {
        // No-op: expenditure is derived from user profile
    }
}
