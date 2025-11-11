//
//  SetTrackerRowViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

protocol SetTrackerRowInteractor {

}

extension CoreInteractor: SetTrackerRowInteractor { }

@Observable
@MainActor
class SetTrackerRowViewModel {

    private let interactor: SetTrackerRowInteractor
    
    var set: WorkoutSetModel
    let trackingMode: TrackingMode
    let weightUnit: ExerciseWeightUnit
    let distanceUnit: ExerciseDistanceUnit
    let previousSet: WorkoutSetModel?
    let restBeforeSec: Int?
    let onRestBeforeChange: (Int?) -> Void
    let onRequestRestPicker: (String, Int?) -> Void
    let onUpdate: (WorkoutSetModel) -> Void
    
    // Validation state
    var showAlert: AnyAppAlert?
    var showWarmupHelp = false
    
    init(
        interactor: SetTrackerRowInteractor,
        set: WorkoutSetModel,
        trackingMode: TrackingMode,
        weightUnit: ExerciseWeightUnit = .kilograms,
        distanceUnit: ExerciseDistanceUnit = .meters,
        previousSet: WorkoutSetModel? = nil,
        restBeforeSec: Int?,
        onRestBeforeChange: @escaping (Int?) -> Void,
        onRequestRestPicker: @escaping (String, Int?) -> Void = { _, _ in },
        onUpdate: @escaping (WorkoutSetModel) -> Void
    ) {
        self.interactor = interactor
        self.set = set
        self.trackingMode = trackingMode
        self.weightUnit = weightUnit
        self.distanceUnit = distanceUnit
        self.previousSet = previousSet
        self.restBeforeSec = restBeforeSec
        self.onRestBeforeChange = onRestBeforeChange
        self.onRequestRestPicker = onRequestRestPicker
        self.onUpdate = onUpdate
    }
    
    var buttonColor: Color {
        if set.completedAt != nil {
            return .green
        } else if canComplete {
            return .secondary
        } else {
            return .red.opacity(0.6)
        }
    }
    
    var canComplete: Bool {
        switch trackingMode {
        case .weightReps:
            let hasValidWeight = set.weightKg == nil || set.weightKg! >= 0
            let hasValidReps = set.reps != nil && set.reps! > 0
            return hasValidWeight && hasValidReps
            
        case .repsOnly:
            return set.reps != nil && set.reps! > 0
            
        case .timeOnly:
            return set.durationSec != nil && set.durationSec! > 0
            
        case .distanceTime:
            let hasValidDistance = set.distanceMeters != nil && set.distanceMeters! > 0
            let hasValidTime = set.durationSec != nil && set.durationSec! > 0
            return hasValidDistance && hasValidTime
        }
    }
        
    func validateSetData() -> Bool {
        switch trackingMode {
        case .weightReps:
            return validateWeightReps()
        case .repsOnly:
            return validateRepsOnly()
        case .timeOnly:
            return validateTimeOnly()
        case .distanceTime:
            return validateDistanceTime()
        }
    }
    
    func validateWeightReps() -> Bool {
        // Weight must be non-negative (including 0 for bodyweight exercises)
        if let weight = set.weightKg, weight < 0 {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Weight must be a non-negative number")
            return false
        }
        
        // Reps must be positive
        guard let reps = set.reps, reps > 0 else {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
            return false
        }
        
        return true
    }
    
    func validateRepsOnly() -> Bool {
        // Reps must be positive
        guard let reps = set.reps, reps > 0 else {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
            return false
        }
        
        return true
    }
    
    func validateTimeOnly() -> Bool {
        // Time must be positive
        guard let duration = set.durationSec, duration > 0 else {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
            return false
        }
        
        return true
    }
    
    func validateDistanceTime() -> Bool {
        // Distance must be positive
        guard let distance = set.distanceMeters, distance > 0 else {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Distance must be a positive number")
            return false
        }
        
        // Time must be positive
        guard let duration = set.durationSec, duration > 0 else {
            showAlert = AnyAppAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
            return false
        }
        
        return true
    }
}
