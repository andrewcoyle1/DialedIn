//
//  TabViewAccessoryPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TabViewAccessoryPresenter {
    
    private let interactor: TabViewAccessoryInteractor
    private let router: TabViewAccessoryRouter

    init(
        interactor: TabViewAccessoryInteractor,
        router: TabViewAccessoryRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    var progress: Double {
        guard let active = interactor.activeSession else { return 0 }
        return Double(completedSetsCount(active)) / Double(totalSetsCount(active))
    }

    var progressLabel: String {
        guard let active = interactor.activeSession else { return "" }
        return "\(completedSetsCount(active))/\(totalSetsCount(active)) sets"
    }
    
    var isRestActive: Bool {
        guard let end = interactor.restEndTime else { return false }
        return Date() < end
    }
    
    var restEndTime: Date? {
        interactor.restEndTime
    }
    
    func reopenActiveSession(activeSession: WorkoutSessionModel) {
        router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSession: activeSession))
    }

    func completedSetsCount(_ session: WorkoutSessionModel) -> Int {
        session.exercises.flatMap(\.sets).filter { $0.completedAt != nil }.count
    }

    func totalSetsCount(_ session: WorkoutSessionModel) -> Int {
        session.exercises.flatMap(\.sets).count
    }

    func totalVolume(_ session: WorkoutSessionModel) -> Double {
        session.exercises.flatMap(\.sets)
            .compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
    }
}
