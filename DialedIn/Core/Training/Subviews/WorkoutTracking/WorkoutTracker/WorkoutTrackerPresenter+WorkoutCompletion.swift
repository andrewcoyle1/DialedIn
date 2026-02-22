//
//  WorkoutTrackerPresenter+WorkoutCompletion.swift
//  DialedIn
//
//  Extracted for type_body_length.
//

import Foundation

// MARK: - Workout Completion
extension WorkoutTrackerPresenter {
    
    func finishWorkout() {
        stopWidgetSyncTimer()
        Task {
            do {
                interactor.trackEvent(
                    eventName: "finish_workout_debug",
                    parameters: [
                        "session_id": workoutSession.id,
                        "template_id": workoutSession.workoutTemplateId ?? "nil",
                        "scheduled_id": workoutSession.scheduledWorkoutId ?? "nil",
                        "plan_id": workoutSession.trainingPlanId ?? "nil"
                    ],
                    type: .info
                )
                
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                // End HK session first
                interactor.endWorkout()
                #endif
                
                let endTime = Date()
                
                // Cancel any pending rest timer notifications
//                await interactor.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
                
                // Update session end time
                workoutSession.endSession(at: endTime)
                self.workoutSession = workoutSession
                try interactor.endLocalWorkoutSession(id: workoutSession.id, at: endTime)
                
                // Save to remote
                try await interactor.createWorkoutSession(session: workoutSession)
                try await interactor.endWorkoutSession(id: workoutSession.id, at: endTime)
                
                // Create exercise history entries (remote + local)
                try await createExerciseHistoryEntries(performedAt: endTime)
                
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                interactor.endLiveActivity(session: workoutSession, isCompleted: true, statusMessage: "Workout ended & saved.")
                #endif
                SharedWorkoutStorage.clearHKStartedSessionId()
                await interactor.endActiveSession(markScheduledComplete: true)
                await MainActor.run {
                    self.router.dismissScreen()
                }
            } catch {
                await MainActor.run {
                    self.router.showSimpleAlert(title: "Failed to finish workout", subtitle: error.localizedDescription)
                }
            }
        }
    }
    
    private func createExerciseHistoryEntries(performedAt: Date) async throws {
        guard let userId = interactor.currentUser?.userId else {
            throw NSError(domain: "WorkoutTrackerPresenter", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Create exercise history entries for each exercise in the session
        for workoutExercise in workoutSession.exercises {
            let historyEntry = ExerciseHistoryEntryModel.newEntry(params: ExerciseHistoryEntryModel.NewEntryParams(
                authorId: userId,
                templateId: workoutExercise.templateId,
                templateName: workoutExercise.name,
                workoutSessionId: workoutSession.id,
                workoutExerciseId: workoutExercise.id,
                performedAt: performedAt,
                notes: workoutExercise.notes,
                sets: workoutExercise.sets
            ))
            
            // Save to local storage
            try interactor.addLocalExerciseHistory(entry: historyEntry)
            
            // Save to remote storage
            try await interactor.createExerciseHistory(entry: historyEntry)
        }
    }
}
