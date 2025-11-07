//
//  SplitViewContainerViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/11/2025.
//

import SwiftUI

protocol SplitViewContainerInteractor {
    var activeSession: WorkoutSessionModel? { get }
    var isTrackerPresented: Bool { get }
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel?
    func setActiveSession(_ session: WorkoutSessionModel?)
    func setIsTrackerPresented(_ presented: Bool)
}

extension CoreInteractor: SplitViewContainerInteractor { }

@Observable
@MainActor
class SplitViewContainerViewModel {
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
