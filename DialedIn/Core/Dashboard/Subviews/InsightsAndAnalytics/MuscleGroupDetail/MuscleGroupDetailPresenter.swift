//
//  MuscleGroupDetailPresenter.swift
//  DialedIn
//
//  Created by Cursor on 07/02/2026.
//

import SwiftUI

@Observable
@MainActor
class MuscleGroupDetailPresenter {

    private let interactor: MuscleGroupDetailInteractor
    private let router: MuscleGroupDetailRouter
    private let muscle: Muscles
    private let calendar = Calendar.current

    private(set) var cachedEntries: [MuscleGroupDetailEntry] = []
    private(set) var cachedTimeSeries: [TimeSeriesData.TimeSeries] = []

    init(interactor: MuscleGroupDetailInteractor, router: MuscleGroupDetailRouter, muscle: Muscles) {
        self.interactor = interactor
        self.router = router
        self.muscle = muscle
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

            let templateIds = Set(completed.flatMap { $0.exercises.map(\.templateId) })
            let templates: [String: ExerciseModel]
            if templateIds.isEmpty {
                templates = [:]
            } else {
                let fetched = try await interactor.getExerciseTemplates(
                    ids: Array(templateIds),
                    limitTo: templateIds.count
                )
                templates = Dictionary(uniqueKeysWithValues: fetched.map { ($0.id, $0) })
            }

            var setsByDay: [Date: Double] = [:]
            let startOfDay: (Date) -> Date = { self.calendar.startOfDay(for: $0) }

            for session in completed {
                let sessionDate = session.endedAt ?? session.dateCreated
                let day = startOfDay(sessionDate)

                for exercise in session.exercises {
                    guard let template = templates[exercise.templateId] else { continue }
                    guard let isSecondary = template.muscleGroups[muscle] else { continue }

                    let completedSets = exercise.sets
                        .filter { !$0.isWarmup && $0.completedAt != nil }
                        .count

                    if completedSets > 0 {
                        let factor: Double = isSecondary ? 0.5 : 1.0
                        let weightedSets = Double(completedSets) * factor
                        setsByDay[day, default: 0] += weightedSets
                    }
                }
            }

            let sortedDays = setsByDay.keys.sorted()
            cachedEntries = sortedDays.reversed().map { day in
                let sets = setsByDay[day] ?? 0
                return MuscleGroupDetailEntry(
                    id: day.timeIntervalSince1970.description,
                    date: day,
                    sets: sets
                )
            }

            let seriesData = sortedDays.map { day in
                TimeSeriesDatapoint(
                    id: day.timeIntervalSince1970.description,
                    date: day,
                    value: setsByDay[day] ?? 0
                )
            }
            cachedTimeSeries = [
                TimeSeriesData.TimeSeries(name: "Sets", data: seriesData)
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

extension MuscleGroupDetailPresenter: @MainActor MetricDetailPresenter {
    typealias Entry = MuscleGroupDetailEntry

    var entries: [MuscleGroupDetailEntry] {
        cachedEntries
    }

    var timeSeries: [TimeSeriesData.TimeSeries] {
        cachedTimeSeries
    }

    var configuration: MetricConfiguration {
        MetricConfiguration(
            title: muscle.name,
            analyticsName: "MuscleGroupDetailView",
            yAxisSuffix: " sets",
            seriesNames: ["Sets"],
            showsAddButton: false,
            sectionHeader: "Daily Sets",
            emptyStateMessage: "No sets for \(muscle.name) in recent workouts",
            pageSize: 20,
            chartColor: .blue,
            chartType: .bar
        )
    }

    func onAppear() async {
        await loadData()
    }

    func onAddPressed() {
        // No-op: sets come from workouts
    }
}
