//
//  WorkoutTrackerView+RestTimer.swift
//  DialedIn
//
//  Extracted rest timer controls from WorkoutTrackerView+Logic to reduce file length.
//

import Foundation

extension WorkoutTrackerView {
    // MARK: - Rest Timer Controls
    
    internal var isRestActive: Bool {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        guard let end = hkWorkoutManager.restEndTime else { return false }
        return Date() < end
        #else
        return false
        #endif
    }
    
    internal func startRestTimer(durationSeconds: Int = 0) {
        let duration = durationSeconds > 0 ? durationSeconds : restDurationSeconds
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        hkWorkoutManager.startRest(durationSeconds: duration, session: workoutSession, currentExerciseIndex: currentExerciseIndex)
        // Sync rest timer with manager for tab bar accessory
        workoutSessionManager.restEndTime = hkWorkoutManager.restEndTime
        
        // Schedule local notification for when rest is complete
        if let endTime = hkWorkoutManager.restEndTime {
            Task {
                do {
                    try await pushManager.schedulePushNotification(
                        identifier: restTimerNotificationId,
                        title: "Rest Complete",
                        body: "Time to get back to your workout!",
                        date: endTime
                    )
                } catch {
                    // Silently fail - notification is nice to have but not critical
                    print("Failed to schedule rest timer notification: \(error)")
                }
            }
        }
        #endif
    }
    
    internal func cancelRestTimer() {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Cancel in manager (will also update Live Activity)
        hkWorkoutManager.cancelRest()
        #endif
        
        // Sync rest timer with manager for tab bar accessory
        workoutSessionManager.restEndTime = nil
        
        // Cancel the pending rest timer notification
        Task {
            await pushManager.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
        }
    }
}
