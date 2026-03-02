//
//  WorkoutTrackerPresenter+WorkoutCompletion.swift
//  DialedIn
//
//  Extracted for type_body_length.
//

import Foundation
import UIKit

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
                
                // Update session end time
                workoutSession.endSession(at: endTime)

                // Save to remote
                try await interactor.endWorkoutSession(workoutSession)
                try? await interactor.addWorkoutStreakEvent()

                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                interactor.endLiveActivity(session: workoutSession, isCompleted: true, statusMessage: "Workout ended & saved.")
                #endif
                UIApplication.shared.isIdleTimerDisabled = false
                SharedWorkoutStorage.clearHKStartedSessionId()
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
    
}
