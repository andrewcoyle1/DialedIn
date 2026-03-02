//
//  WorkoutTrackerPresenter+UnitConversion.swift
//  DialedIn
//
//  Extracted for type_body_length.
//

import SwiftUI

// MARK: - Unit Conversion
extension WorkoutTrackerPresenter {
    
    /// Converts weights to new unit, rounds to equipment increments when possible, and updates the workout session
    func convertAndRoundWeights(to newUnit: ExerciseWeightUnit, for exercise: WorkoutExerciseModel) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exercise.id }) else {
            return
        }

        let currentUnit = getUnitPreference(for: exercise.templateId).weightUnit
        var updatedExercises = workoutSession.exercises
        let currentExercise = updatedExercises[exerciseIndex]
        var updatedSets = currentExercise.sets

        for setIndex in updatedSets.indices {
            guard let weightKg = updatedSets[setIndex].weightKg else { continue }

            let weightInNewUnit = UnitConversion.convertWeight(weightKg, from: currentUnit, into: newUnit)
            let weightKgAsNewUnit = UnitConversion.convertWeightToKg(weightInNewUnit, from: newUnit)

            let roundedWeightKg = WorkoutSessionModel.roundWeightToEquipmentIncrement(
                weightKg: weightKgAsNewUnit,
                workoutExercise: currentExercise,
                gymProfile: favouriteGymProfile,
                preferredWeightUnit: newUnit
            )

            let roundedWeightKgFinal: Double
            if roundedWeightKg == weightKgAsNewUnit {
                let roundedWeight: Double
                if newUnit == .kilograms {
                    roundedWeight = round(weightInNewUnit * 2) / 2.0
                } else {
                    roundedWeight = round(weightInNewUnit)
                }
                roundedWeightKgFinal = UnitConversion.convertWeightToKg(roundedWeight, from: newUnit)
            } else {
                roundedWeightKgFinal = roundedWeightKg
            }

            updatedSets[setIndex].weightKg = roundedWeightKgFinal
        }

        updatedExercises[exerciseIndex].sets = updatedSets
        workoutSession.updateExercises(updatedExercises)

        updateWeightUnit(newUnit, for: exercise.templateId)
    }
    
    /// Converts distances to new unit and updates the workout session
    func convertAndRoundDistances(to newUnit: ExerciseDistanceUnit, for exercise: WorkoutExerciseModel) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exercise.id }) else {
            return
        }
        
        let currentUnit = getUnitPreference(for: exercise.templateId).distanceUnit
        var updatedExercises = workoutSession.exercises
        var updatedSets = updatedExercises[exerciseIndex].sets
        
        // Convert each set's distance
        for setIndex in updatedSets.indices {
            if let distanceMeters = updatedSets[setIndex].distanceMeters {
                // Convert to new unit
                let distanceInNewUnit = UnitConversion.convertDistance(distanceMeters, from: currentUnit, into: newUnit)
                
                // Round appropriately
                let roundedDistance: Double
                if newUnit == .meters {
                    roundedDistance = round(distanceInNewUnit) // Round to nearest meter
                } else {
                    roundedDistance = round(distanceInNewUnit * 100) / 100.0 // Round to 2 decimal places for miles
                }
                
                // Convert back to meters for storage
                let roundedDistanceMeters = UnitConversion.convertDistanceToMeters(roundedDistance, from: newUnit)
                updatedSets[setIndex].distanceMeters = roundedDistanceMeters
            }
        }
        
        updatedExercises[exerciseIndex].sets = updatedSets
        workoutSession.updateExercises(updatedExercises)

        updateDistanceUnit(newUnit, for: exercise.templateId)
    }
}
