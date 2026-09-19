//
//  ExerciseModelDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ExerciseModelDetailPresenter {
    private let interactor: ExerciseModelDetailInteractor
    private let router: ExerciseModelDetailRouter

    var section: CustomSection = .description

    var isBookmarked: Bool = false
    var isFavourited: Bool = false
    private(set) var unitPreference: ExerciseUnitPreference?

    init(
        interactor: ExerciseModelDetailInteractor,
        router: ExerciseModelDetailRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    private(set) var stats = ExerciseModelDetailStats()

    /// Rebuilt on appear rather than computed per section: all three history-bearing tabs walk the
    /// same sessions, and the collection only changes when a workout is logged.
    func onViewAppear(delegate: ExerciseModelDetailDelegate) {
        stats = ExerciseModelDetailStats.make(
            from: interactor.workoutSessions,
            templateId: delegate.exerciseModel.id
        )
    }

    var performedSubtitle: String {
        guard let latest = stats.mostRecentFirst.first else { return "No history yet" }
        let times = stats.performances.count
        let noun = times == 1 ? "time" : "times"
        let date = latest.date.formatted(date: .abbreviated, time: .omitted)
        return "Performed \(times) \(noun) · last \(date)"
    }

    /// One point per session, so the charts follow workouts rather than calendar days — this
    /// exercise is not necessarily trained daily.
    var weightSeries: [TimeSeries] {
        let points = stats.performances
            .sorted { $0.date < $1.date }
            .map { TimeSeriesDatapoint(id: $0.sessionId, date: $0.date, value: $0.heaviestWeightKg) }
        return [TimeSeries(name: "Top Set", data: points)]
    }

    var repsSeries: [TimeSeries] {
        let points = stats.performances
            .sorted { $0.date < $1.date }
            .map { TimeSeriesDatapoint(id: $0.sessionId, date: $0.date, value: Double($0.totalReps)) }
        return [TimeSeries(name: "Reps", data: points)]
    }

    /// Sessions whose estimated 1-RM beat every session before it, newest first.
    var oneRMRecords: [ExerciseModelDetailStats.Performance] {
        var best: Double = 0
        var records: [ExerciseModelDetailStats.Performance] = []
        for performance in stats.performances.sorted(by: { $0.date < $1.date }) where performance.bestOneRMKg > best {
            best = performance.bestOneRMKg
            records.append(performance)
        }
        return records.reversed()
    }

    func formattedWeight(_ kilos: Double) -> String {
        let unit = unitPreference?.weightUnit ?? .kilograms
        if unit == .pounds {
            return String(format: "%.0f lbs", UnitConversion.kgToLbs(kilos))
        }
        return String(format: "%.0f kg", kilos)
    }

    func formattedVolume(_ kilos: Double) -> String {
        formattedWeight(kilos)
    }
        
    func onDismissPressed() {
        router.dismissScreen()
    }
    
#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif
}

enum CustomSection: Hashable {
    case description
    case history
    case charts
    case records
}
