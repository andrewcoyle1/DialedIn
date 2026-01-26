//
//  AdaptiveMainInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

protocol AdaptiveMainInteractor {
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel?
}

extension CoreInteractor: AdaptiveMainInteractor { }
