//
//  SplitViewContainerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/11/2025.
//

import SwiftUI

@Observable
@MainActor
class SplitViewContainerPresenter {
    private let interactor: SplitViewContainerInteractor
    
    var preferredColumn: NavigationSplitViewColumn = .sidebar

    var activeSession: WorkoutSessionModel? {
        get { interactor.activeSession }
        set { interactor.setActiveSession(newValue) }
    }
    
    var isTrackerPresented: Bool {
        get { interactor.isTrackerPresented }
        set { interactor.setIsTrackerPresented(newValue) }
    }
    
    init(interactor: SplitViewContainerInteractor) {
        self.interactor = interactor
    }
    
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel? {
        try interactor.getActiveLocalWorkoutSession()
    }
}
