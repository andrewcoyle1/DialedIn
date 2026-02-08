//
//  WorkoutPresenter.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@Observable
@MainActor
class WorkoutPresenter {

    private let interactor: WorkoutInteractor
    private let router: WorkoutRouter
    private let calendar = Calendar.current

    private(set) var cachedEntries: [WorkoutEntry] = []
    private(set) var cachedTimeSeries: [TimeSeriesData.TimeSeries] = []

    init(interactor: WorkoutInteractor, router: WorkoutRouter) {
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
        guard let userId = interactor.auth?.uid else {
            cachedEntries = []
            cachedTimeSeries = []
            return
        }
        do {
            let sessions = try interactor.getLocalWorkoutSessionsForAuthor(
                authorId: userId,
                limitTo: 0
            )
            let completed = sessions
                .filter { $0.endedAt != nil }
                .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }

            cachedEntries = completed.map { session in
                let date = session.endedAt ?? session.dateCreated
                let sets = session.exercises.flatMap { $0.sets }.filter { !$0.isWarmup }.count
                let volume = session.exercises.flatMap { $0.sets }
                    .filter { !$0.isWarmup }
                    .compactMap { set -> Double? in
                        guard let weight = set.weightKg, let reps = set.reps else { return nil }
                        return weight * Double(reps)
                    }
                    .reduce(0, +)
                return WorkoutEntry(
                    id: session.id,
                    date: date,
                    name: session.name,
                    sets: sets,
                    volumeKg: volume
                )
            }

            let sortedEntries = cachedEntries.sorted { $0.date < $1.date }
            let seriesData = sortedEntries.map { entry in
                TimeSeriesDatapoint(id: entry.id, date: entry.date, value: Double(entry.sets))
            }
            cachedTimeSeries = [
                TimeSeriesData.TimeSeries(name: "Sets", data: seriesData)
            ]
        } catch {
            cachedEntries = []
            cachedTimeSeries = []
        }
    }
}

extension WorkoutPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = WorkoutEntry

    var entries: [WorkoutEntry] {
        cachedEntries
    }

    var timeSeries: [TimeSeriesData.TimeSeries] {
        cachedTimeSeries
    }

    var contributionChartData: [Double]? {
        let endDate = calendar.startOfDay(for: Date())
        let totalDays = 3 * 10
        guard let chartStartDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endDate) else { return nil }
        let workoutDates = Set(cachedEntries.map { calendar.startOfDay(for: $0.date) })
        var data = Array(repeating: 0.0, count: 30)
        for column in 0..<10 {
            for row in 0..<3 {
                let dayOffset = column * 3 + row
                guard let cellDate = calendar.date(byAdding: .day, value: dayOffset, to: chartStartDate),
                      dayOffset < 30 else { continue }
                if workoutDates.contains(calendar.startOfDay(for: cellDate)) {
                    data[dayOffset] = 1.0
                }
            }
        }
        return data
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: "Workouts",
            analyticsName: "WorkoutsView",
            yAxisSuffix: "",
            seriesNames: ["Sets"],
            showsAddButton: false,
            sectionHeader: "Workout History",
            emptyStateMessage: "No completed workouts",
            pageSize: 20,
            chartColor: .orange,
            chartType: .bar
        )
    }

    func onAppear() async {
        loadData()
    }

    func onAddPressed() {
        // No-op: user starts workouts from Training tab
    }

    func onDeleteEntry(_ entry: WorkoutEntry) async {
        // Workout deletion would go through WorkoutSessionDetail; no-op here
    }
}
