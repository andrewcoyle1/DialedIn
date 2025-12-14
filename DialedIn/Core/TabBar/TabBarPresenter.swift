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
        get { interactor.isTrackerPresented }
        set { interactor.setIsTrackerPresented(newValue) }
    }

    init(
        interactor: TabBarInteractor
    ) {
        self.interactor = interactor
    }
        
    func checkForActiveSession() {
        activeSession = try? interactor.getActiveLocalWorkoutSession() 
    }
    
    func onWorkoutAccessoryPressed() {
        guard activeSession != nil else { return }
        isTrackerPresented = true
    }
}
