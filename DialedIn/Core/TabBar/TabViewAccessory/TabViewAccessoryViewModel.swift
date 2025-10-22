//
//  TabViewAccessoryViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TabViewAccessoryViewModel {
    private let workoutSessionManager: WorkoutSessionManager
    
    init(
        container: DependencyContainer
    ) {
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
    }
    
    var progress: Double {
        guard let active = workoutSessionManager.activeSession else { return 0 }
        return Double(completedSetsCount(active)) / Double(totalSetsCount(active))
    }

    var progressLabel: String {
        guard let active = workoutSessionManager.activeSession else { return "" }
        return "\(completedSetsCount(active))/\(totalSetsCount(active)) sets"
    }
    
    var isRestActive: Bool {
        guard let end = workoutSessionManager.restEndTime else { return false }
        return Date() < end
    }
    
    var restEndTime: Date? {
        workoutSessionManager.restEndTime
    }
    
    func reopenActiveSession() {
        workoutSessionManager.reopenActiveSession()
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
