//
//  ExerciseDetailPresenter.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@Observable
@MainActor
class ExerciseDetailPresenter {

    private let interactor: ExerciseDetailInteractor
    private let router: ExerciseDetailRouter
    private let templateId: String
    private let name: String
    private let calendar = Calendar.current

    private(set) var cachedEntries: [ExerciseDetailEntry] = []
    private(set) var cachedTimeSeries: [TimeSeriesData.TimeSeries] = []

    init(interactor: ExerciseDetailInteractor, router: ExerciseDetailRouter, templateId: String, name: String) {
        self.interactor = interactor
        self.router = router
        self.templateId = templateId
        self.name = name
    }

    func loadData() async {
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

            var oneRMByDay: [Date: Double] = [:]
            let startOfDay: (Date) -> Date = { self.calendar.startOfDay(for: $0) }

            for session in completed {
                let sessionDate = session.endedAt ?? session.dateCreated
                let day = startOfDay(sessionDate)

                for exercise in session.exercises where exercise.templateId == templateId {
                    let best1RM = exercise.sets
                        .filter { !$0.isWarmup && $0.completedAt != nil }
                        .compactMap { set -> Double? in
                            guard let weight = set.weightKg, weight > 0 else { return nil }
                            let reps = set.reps ?? 1
                            return ExerciseOneRMAggregator.estimated1RM(weightKg: weight, reps: max(1, reps))
                        }
                        .max()

                    if let oneRM = best1RM, oneRM > 0 {
                        oneRMByDay[day] = max(oneRMByDay[day] ?? 0, oneRM)
                    }
                }
            }

            let sortedDays = oneRMByDay.keys.sorted()
            cachedEntries = sortedDays.reversed().map { day in
                ExerciseDetailEntry(
                    id: day.timeIntervalSince1970.description,
                    date: day,
                    oneRMKg: oneRMByDay[day] ?? 0
                )
            }

            let seriesData = sortedDays.map { day in
                TimeSeriesDatapoint(
                    id: day.timeIntervalSince1970.description,
                    date: day,
                    value: oneRMByDay[day] ?? 0
                )
            }
            cachedTimeSeries = [
                TimeSeriesData.TimeSeries(name: "1-RM", data: seriesData)
            ]
        } catch {
            cachedEntries = []
            cachedTimeSeries = []
        }
    }

    func onDismissPressed() {
        router.dismissScreen()
    }
}

extension ExerciseDetailPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = ExerciseDetailEntry

    var entries: [ExerciseDetailEntry] {
        cachedEntries
    }

    var timeSeries: [TimeSeriesData.TimeSeries] {
        cachedTimeSeries
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: name,
            analyticsName: "ExerciseDetailView",
            yAxisSuffix: " kg",
            seriesNames: ["1-RM"],
            showsAddButton: false,
            sectionHeader: "Daily 1-RM",
            emptyStateMessage: "No 1-RM data for \(name)",
            pageSize: 20,
            chartColor: .blue,
            chartType: .bar
        )
    }

    func onAppear() async {
        await loadData()
    }

    func onAddPressed() {
        // No-op: 1-RM comes from workouts
    }
}
