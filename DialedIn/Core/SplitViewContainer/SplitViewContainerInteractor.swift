//
//  SplitViewContainerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol SplitViewContainerInteractor {
    var activeSession: WorkoutSessionModel? { get }
    var isTrackerPresented: Bool { get }
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel?
    func setActiveSession(_ session: WorkoutSessionModel?)
    func setIsTrackerPresented(_ presented: Bool)
}

extension CoreInteractor: SplitViewContainerInteractor { }
