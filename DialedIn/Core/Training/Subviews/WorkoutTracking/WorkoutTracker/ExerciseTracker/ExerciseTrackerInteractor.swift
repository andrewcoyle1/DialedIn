//
//  ExerciseTrackerInteractor.swift
//  DialedIn
//
//  Created by Andrew Coyle on 02/03/2026.
//

@MainActor
protocol ExerciseTrackerInteractor: GlobalInteractor {
    
    var favouriteGymProfile: GymProfileModel? { get }

    /// Set the weight unit preference for a specific exercise template
    func setWeightUnit(_ unit: ExerciseWeightUnit, for templateId: String)
    
    /// Set the distance unit preference for a specific exercise template
    func setDistanceUnit(_ unit: ExerciseDistanceUnit, for templateId: String)

}

extension CoreInteractor: ExerciseTrackerInteractor { }
