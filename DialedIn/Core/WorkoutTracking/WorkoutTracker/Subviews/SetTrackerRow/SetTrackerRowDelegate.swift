//
//  SetTrackerRowDelegate.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/11/2025.
//

struct SetTrackerRowDelegate {
    var set: WorkoutSetModel
    let trackingMode: TrackingMode
    var weightUnit: ExerciseWeightUnit = .kilograms
    var distanceUnit: ExerciseDistanceUnit = .meters
    var previousSet: WorkoutSetModel?
    var restBeforeSec: Int?
    let onRestBeforeChange: (Int?) -> Void
    var onRequestRestPicker: (String, Int?) -> Void = { _, _ in }
    let onUpdate: (WorkoutSetModel) -> Void
}
