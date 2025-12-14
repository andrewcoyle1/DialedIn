//
//  ExerciseTrackerCardPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Foundation

@Observable
@MainActor
class ExerciseTrackerCardPresenter {
    private let interactor: ExerciseTrackerCardInteractor
    private let router: ExerciseTrackerCardRouter
    
    private(set) var preference: ExerciseUnitPreference?

    var notesDraft: String = ""
    
    init(
        interactor: ExerciseTrackerCardInteractor,
        router: ExerciseTrackerCardRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadExerciseNotes(_ exercise: WorkoutExerciseModel) {
        self.notesDraft = exercise.notes ?? ""
    }
    
    func loadUnitPreferences(for templateId: String) {
        preference = interactor.getPreference(templateId: templateId)
    }
    
    func updateWeightUnit(_ unit: ExerciseWeightUnit, for templateId: String) {
        interactor.setWeightUnit(unit, for: templateId)
    }
    
    func updateDistanceUnit(_ unit: ExerciseDistanceUnit, for templateId: String) {
        interactor.setDistanceUnit(unit, for: templateId)
    }
    
    func makeSetDelegate(for set: WorkoutSetModel, exercise: WorkoutExerciseModel, parentDelegate: ExerciseTrackerCardDelegate) -> SetTrackerRowDelegate {
        let previousSet = exercise.sets.first(where: { $0.index == set.index - 1 })
        return SetTrackerRowDelegate(
            set: set,
            trackingMode: exercise.trackingMode,
            weightUnit: preference?.weightUnit ?? .kilograms,
            distanceUnit: preference?.distanceUnit ?? .meters,
            previousSet: previousSet,
            restBeforeSec: parentDelegate.restBeforeSetIdToSec[set.id],
            onRestBeforeChange: { newValue in
                parentDelegate.onRestBeforeChange(set.id, newValue)
            },
            onRequestRestPicker: { setId, value in
                parentDelegate.onRequestRestPicker(setId, value)
            },
            onUpdate: { updatedSet in
                parentDelegate.onUpdateSet(updatedSet, exercise.id)
            }
        )
    }
}
