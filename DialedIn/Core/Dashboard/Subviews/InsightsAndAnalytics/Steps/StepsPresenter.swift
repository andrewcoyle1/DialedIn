//
//  StepsPresenter.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@Observable
@MainActor
class StepsPresenter {

    private let interactor: StepsInteractor
    private let router: StepsRouter
    private let calendar = Calendar.current

    private(set) var cachedEntries: [StepsEntry] = []
    private(set) var cachedTimeSeries: [TimeSeriesData.TimeSeries] = []

    init(interactor: StepsInteractor, router: StepsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func loadData() async {
        if interactor.canRequestHealthDataAuthorisation() {
            do {
                try await interactor.requestHealthKitAuthorisation()
            } catch {
                // User denied or failed - continue to load; will show empty if no access
            }
        }
        await interactor.backfillStepsFromHealthKit()
        _ = try? interactor.readAllLocalStepsEntries()
        let history = interactor.stepsHistory
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let startDate = calendar.date(byAdding: .day, value: -89, to: startOfToday) else {
            cachedEntries = []
            cachedTimeSeries = []
            return
        }
        let userId = interactor.userId
        let last90 = history
            .filter { $0.deletedAt == nil && $0.date >= startDate && $0.date <= startOfToday && (userId == nil || $0.authorId == userId) }
            .sorted { $0.date < $1.date }
        let consolidated = Self.consolidateStepsByDay(Array(last90))
        cachedEntries = consolidated
            .map { StepsEntry(id: $0.id, date: $0.date, steps: $0.number) }
            .reversed()
        let seriesData = consolidated.map { step in
            TimeSeriesDatapoint(id: step.id, date: step.date, value: Double(step.number))
        }
        cachedTimeSeries = [
            TimeSeriesData.TimeSeries(name: "Steps", data: seriesData)
        ]
    }

    private static func consolidateStepsByDay(_ entries: [StepsModel]) -> [StepsModel] {
        let byDay = Dictionary(grouping: entries) { Calendar.current.startOfDay(for: $0.date) }
        return byDay.compactMap { (_, dayEntries) in
            dayEntries.max { $0.number < $1.number }
        }.sorted { $0.date < $1.date }
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}

extension StepsPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = StepsEntry

    var entries: [StepsEntry] {
        cachedEntries
    }

    var timeSeries: [TimeSeriesData.TimeSeries] {
        cachedTimeSeries
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Steps",
            analyticsName: "StepsView",
            yAxisSuffix: "",
            seriesNames: ["Steps"],
            showsAddButton: false,
            sectionHeader: "Daily Steps",
            emptyStateMessage: "No step data",
            pageSize: 20,
            chartType: .bar
        )
    }

    func onAppear() async {
        await loadData()
    }

    func onAddPressed() {
        // TODO: Show add steps view
    }

}
