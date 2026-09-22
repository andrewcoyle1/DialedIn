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
    private(set) var cachedTimeSeries: [TimeSeries] = []

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
            TimeSeries(name: "Expenditure", data: data)
        ]
    }
}

extension ExpenditureDetailPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = ExpenditureDetailEntry

    var entries: [ExpenditureDetailEntry] {
        cachedEntries
    }

    var timeSeries: [TimeSeries] {
        cachedTimeSeries
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Expenditure",
            analyticsName: "ExpenditureDetailView",
            yAxisSuffix: "",
            seriesNames: ["Expenditure"],
            showsAddButton: true,
            sectionHeader: "Daily Expenditure",
            emptyStateMessage: "No expenditure data",
            chartType: .line,
            addActionTitle: "Edit Profile",
            addActionSystemImage: "person.crop.circle"
        )
    }

    func onAppear() async {
        loadData()
    }

    func onAddPressed() {
        // TDEE is estimated from height, weight, age and activity level — all of which live on
        // the account screen, which is where this now goes.
        router.showAccountView(delegate: AccountDelegate())
    }

}
