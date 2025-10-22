//
//  TabBarViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TabBarViewModel {
    
    private let workoutSessionManager: WorkoutSessionManager

    var presentTracker: Bool = false

    init(
        container: DependencyContainer
    ) {
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
    }

    var active: WorkoutSessionModel? {
        workoutSessionManager.activeSession = checkForActiveSession()
        return workoutSessionManager.activeSession
    }
    
    var trackerPresented: Bool {
        workoutSessionManager.isTrackerPresented
    }
    
    func checkForActiveSession() -> WorkoutSessionModel? {
        try? workoutSessionManager.getActiveLocalWorkoutSession()
    }
}
