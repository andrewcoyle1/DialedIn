//
//  TabBarInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol TabBarInteractor {
    var activeSession: WorkoutSessionModel? { get }
    func setActiveSession(_ session: WorkoutSessionModel?)
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel?
}

extension CoreInteractor: TabBarInteractor { }
