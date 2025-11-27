//
//  TabBarPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TabBarPresenter {
    
    private let interactor: TabBarInteractor

    var activeSession: WorkoutSessionModel? {
        get {
            interactor.activeSession
        }
        set {
            interactor.setActiveSession(newValue)
        }
    }

    var isTrackerPresented: Bool {
        get {
            interactor.isTrackerPresented
        }
        set {
            interactor.setIsTrackerPresented(newValue)
        }
    }

    init(
        interactor: TabBarInteractor
    ) {
        self.interactor = interactor
    }

    var active: WorkoutSessionModel? {
        interactor.activeSession
    }
    
    var trackerPresented: Bool {
        interactor.isTrackerPresented
    }
    
    func checkForActiveSession() -> WorkoutSessionModel? {
        if let session = try? interactor.getActiveLocalWorkoutSession() {
            activeSession = session
            return session
        }
        return nil
    }
}
