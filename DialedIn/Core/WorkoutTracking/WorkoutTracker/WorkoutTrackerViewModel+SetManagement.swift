//
//  WorkoutTrackerViewModel+SetManagement.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import Foundation
import SwiftUI

// MARK: - Set Management
extension WorkoutTrackerViewModel {
    func updateSet(_ updatedSet: WorkoutSetModel, in exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }),
              let setIndex = workoutSession.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == updatedSet.id }) else {
            return
        }
        let exerciseBefore = workoutSession.exercises[exerciseIndex]
        let wasExerciseCompleteBefore = !exerciseBefore.sets.isEmpty && exerciseBefore.sets.allSatisfy { $0.completedAt != nil }

        var updatedExercises = workoutSession.exercises
        let previousCompletedAt = updatedExercises[exerciseIndex].sets[setIndex].completedAt
        updatedExercises[exerciseIndex].sets[setIndex] = updatedSet
        let isExerciseCompleteNow = !updatedExercises[exerciseIndex].sets.isEmpty && updatedExercises[exerciseIndex].sets.allSatisfy { $0.completedAt != nil }
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()
        
        let allSets = updatedExercises.flatMap { $0.sets }
        let isAllSetsComplete = !allSets.isEmpty && allSets.allSatisfy { $0.completedAt != nil }
        
        if previousCompletedAt == nil, updatedSet.completedAt != nil, !isAllSetsComplete {
            let customForThisSet = restBeforeSetIdToSec[updatedSet.id]
            startRestTimer(durationSeconds: customForThisSet ?? restDurationSeconds)
        }
        
        if !wasExerciseCompleteBefore && isExerciseCompleteNow {
            let nextIndex = exerciseIndex + 1
            if nextIndex < updatedExercises.count {
                expandedExerciseIds.removeAll()
                expandedExerciseIds.insert(updatedExercises[nextIndex].id)
                print("🔄 Current exercise index changed: \(currentExerciseIndex) → \(nextIndex) (reason: exercise completed)")
                currentExerciseIndex = nextIndex
            } else {
                expandedExerciseIds.remove(updatedExercises[exerciseIndex].id)
            }
        }

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    func addSet(to exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }),
              let userId = interactor.currentUser?.userId else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        let exercise = updatedExercises[exerciseIndex]
        let newIndex = exercise.sets.count + 1
        
        let lastSet = exercise.sets.last
        let newSet = WorkoutSetModel(
            id: UUID().uuidString,
            authorId: userId,
            index: newIndex,
            reps: lastSet?.reps,
            weightKg: lastSet?.weightKg,
            durationSec: lastSet?.durationSec,
            distanceMeters: lastSet?.distanceMeters,
            rpe: lastSet?.rpe,
            isWarmup: false,
            completedAt: nil,
            dateCreated: Date()
        )
        
        updatedExercises[exerciseIndex].sets.append(newSet)
        if let last = lastKnownRestForExercise(exerciseIndex: exerciseIndex) {
            restBeforeSetIdToSec[newSet.id] = last
        }
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
    
    func deleteSet(_ setId: String, from exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].sets.removeAll { $0.id == setId }
        restBeforeSetIdToSec.removeValue(forKey: setId)
        
        for index in updatedExercises[exerciseIndex].sets.indices {
            updatedExercises[exerciseIndex].sets[index].index = index + 1
        }
        
        workoutSession.updateExercises(updatedExercises)
        saveWorkoutProgress()

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        )
        #endif
    }
}
