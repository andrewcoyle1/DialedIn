//
//  EnergyBalancePresenter.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@Observable
@MainActor
class EnergyBalancePresenter {

    private let interactor: EnergyBalanceInteractor
    private let router: EnergyBalanceRouter
    private let calendar = Calendar.current

    private(set) var cachedEntries: [EnergyBalanceEntry] = []
    private(set) var cachedExpenditure: TimeSeriesData.TimeSeries = TimeSeriesData.TimeSeries(name: "Expenditure", data: [])
    private(set) var cachedIntake: TimeSeriesData.TimeSeries = TimeSeriesData.TimeSeries(name: "Intake", data: [])

    init(interactor: EnergyBalanceInteractor, router: EnergyBalanceRouter) {
        self.interactor = interactor
        self.router = router
        rebuildCaches()
    }

    func loadData() {
        rebuildCaches()
    }

    func onAddMealPressed() {
        let delegate = AddMealDelegate(
            selectedDate: Date(),
            mealType: .snack,
            onSave: { [weak self] _ in
                self?.loadData()
            }
        )
        router.showAddMealView(delegate: delegate)
    }

    func onDismissPressed() {
        router.dismissScreen()
    }

    private func rebuildCaches() {
        let tdee = interactor.estimateTDEE(user: interactor.currentUser)
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startDate = calendar.date(byAdding: .day, value: -89, to: startOfToday) else {
            return
        }
        let startDayKey = startDate.dayKey
        let endDayKey = startOfToday.dayKey

        let totalsData = (try? interactor.getDailyTotals(startDayKey: startDayKey, endDayKey: endDayKey)) ?? []

        var entries: [EnergyBalanceEntry] = []
        var expenditureData: [TimeSeriesDatapoint] = []
        var intakeData: [TimeSeriesDatapoint] = []

        let dateKeys = Date.dayKeys(from: startDate, to: startOfToday)
        for (index, dayKey) in dateKeys.enumerated() {
            guard let date = Date(dayKey: dayKey) else { continue }
            let totals = totalsData.first { $0.dayKey == dayKey }?.totals ?? DailyMacroTarget(calories: 0, proteinGrams: 0, carbGrams: 0, fatGrams: 0)

            let entry = EnergyBalanceEntry(
                id: dayKey,
                date: date,
                expenditure: tdee,
                intake: totals.calories
            )
            entries.append(entry)

            expenditureData.append(TimeSeriesDatapoint(id: "exp-\(index)", date: date, value: tdee))
            intakeData.append(TimeSeriesDatapoint(id: "intake-\(index)", date: date, value: totals.calories))
        }

        cachedEntries = entries.reversed()
        cachedExpenditure = TimeSeriesData.TimeSeries(name: "Expenditure", data: expenditureData)
        cachedIntake = TimeSeriesData.TimeSeries(name: "Intake", data: intakeData)
    }
}

extension EnergyBalancePresenter: @MainActor MetricDetailPresenter {
    typealias Entry = EnergyBalanceEntry

    var entries: [EnergyBalanceEntry] {
        cachedEntries
    }

    var timeSeries: [TimeSeriesData.TimeSeries] {
        [cachedExpenditure, cachedIntake]
    }

    var customChartView: AnyView? {
        AnyView(
            EnergyBalanceChart(
                expenditure: cachedExpenditure,
                energyIntake: cachedIntake,
                maxVisibleDays: nil
            )
        )
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Energy Balance",
            analyticsName: "EnergyBalanceView",
            yAxisSuffix: "",
            seriesNames: ["Expenditure", "Intake"],
            showsAddButton: true,
            sectionHeader: "Daily Balance",
            emptyStateMessage: "No data for the last 90 days",
            pageSize: 20,
            chartColor: nil
        )
    }

    func onAppear() async {
        loadData()
    }

    func onAddPressed() {
        onAddMealPressed()
    }

    func onDeleteEntry(_ entry: EnergyBalanceEntry) async {
        // Energy balance entries are derived from meals; deletion would clear meals for that day
        // For now, no-op. User can manage meals from Nutrition.
    }
}
