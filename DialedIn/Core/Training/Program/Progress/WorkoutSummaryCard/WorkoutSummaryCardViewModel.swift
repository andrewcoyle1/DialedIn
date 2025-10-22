//
//  WorkoutSummaryCardViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutSummaryCardViewModel {
    private let workoutSessionManager: WorkoutSessionManager
    let scheduledWorkout: ScheduledWorkout
    let onTap: () -> Void
    
    private(set) var session: WorkoutSessionModel?
    private(set) var isLoading = true
    var showAlert: AnyAppAlert?
    init(
        container: DependencyContainer,
        scheduledWorkout: ScheduledWorkout,
        onTap: @escaping () -> Void
    ) {
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.scheduledWorkout = scheduledWorkout
        self.onTap = onTap
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func calculateTotalVolume(session: WorkoutSessionModel) -> Double {
        session.exercises.flatMap { $0.sets }
            .filter { $0.completedAt != nil }
            .compactMap { set -> Double? in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
    }
    
    func loadSession() async {
        guard let sessionId = scheduledWorkout.completedSessionId else {
            isLoading = false
            return
        }
        
        do {
            let fetchedSession = try await workoutSessionManager.getWorkoutSession(id: sessionId)
            await MainActor.run {
                self.session = fetchedSession
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.showAlert = AnyAppAlert(error: error)
            }
        }
    }
}
