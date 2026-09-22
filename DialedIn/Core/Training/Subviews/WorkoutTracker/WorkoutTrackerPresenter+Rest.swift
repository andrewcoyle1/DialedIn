//
//  WorkoutTrackerPresenter+Rest.swift
//  DialedIn
//
//  Split out of WorkoutTrackerPresenter.swift, which exceeded the 500-line type-body limit.
//  Everything the screen does about resting between sets, and the previous-values lookup the
//  rest of the screen reads alongside it.
//

import SwiftUI

extension WorkoutTrackerPresenter {

    var restDurationSeconds: Int {
        interactor.workoutSettings.defaultRestDurationSeconds
    }

    var restEndTime: Date? {
        interactor.restEndTime
    }

    var isRestActive: Bool {
        guard let end = interactor.restEndTime else { return false }
        return Date() < end
    }

    // MARK: - Previous Values

    /// The program the "previous" figures may come from, or `nil` for any workout at all.
    ///
    /// `.workoutsInProgram` means "the same program as this workout", so a session logged outside
    /// a program has no program to be within and keeps the unrestricted lookup — otherwise the
    /// setting would silently blank the previous column for every one-off workout.
    private var previousWorkoutReferenceProgramId: String? {
        switch interactor.workoutSettings.previousWorkoutReference {
        case .anyWorkout:        return nil
        case .workoutsInProgram: return workoutSession.trainingProgramId
        }
    }

    func loadPreviousWorkoutSession() {
        // Only load previous session if this workout is from a template
        guard let templateId = workoutSession.workoutTemplateId,
              let authorId = interactor.currentUser?.userId else {
            previousWorkoutSession = nil
            return
        }

        Task {
            do {
                previousWorkoutSession = try await interactor.getLastCompletedSessionForTemplate(
                    templateId: templateId,
                    authorId: authorId,
                    inTrainingProgramId: previousWorkoutReferenceProgramId
                )
            } catch {
                previousWorkoutSession = nil
            }
        }
    }

    func cancelRestTimer() {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Cancel in manager (will also update Live Activity)
        interactor.cancelRest()
        #endif

    }

    /// Announces every rest that runs out while this screen is up. Driven from its own `.task` so
    /// the loop is cancelled when the screen goes away — an observer token outliving the presenter
    /// would announce rests for a workout nobody is looking at.
    func observeRestCompletions() async {
        for await _ in NotificationCenter.default.notifications(named: Constants.workoutRestDidComplete) {
            announceRestCompletion()
        }
    }

    /// Sound and vibration are asked for separately, so a user who wants one without the other in a
    /// quiet gym gets exactly that.
    func announceRestCompletion() {
        let settings = interactor.workoutSettings
        if settings.restTimerPlaySound {
            interactor.playSoundEffect(sound: .restComplete)
        }
        if settings.restTimerVibrate {
            interactor.playHaptic(option: .success)
        }
    }

    func startRestTimer(durationSeconds: Int = 0) {
        let duration = durationSeconds > 0 ? durationSeconds : restDurationSeconds
        // Preparing is idempotent, and doing it as the rest starts means the players are loaded by
        // the time it ends rather than being built during the moment they are wanted.
        if interactor.workoutSettings.restTimerPlaySound {
            interactor.prepareSoundEffect(sound: .restComplete, simultaneousPlayers: 1)
        }
        interactor.trackEvent(event: Event.startRestTimerCalled(inputDuration: durationSeconds, resolvedDuration: duration))
        interactor.startRest(durationSeconds: duration, session: workoutSession, currentExerciseIndex: currentExerciseIndex)
        interactor.trackEvent(event: Event.startRestTimerAfterCall(restEndTime: interactor.restEndTime))

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Schedule local notification for when rest is complete
        if let endTime = interactor.restEndTime {
            Task {
                do {
                    let delegate = PushNotificationDelegate(
                        identifier: restTimerNotificationId,
                        title: "Rest Complete",
                        subtitle: "Time to get back to your workout!",
                        triggerDate: endTime,
                        // The same setting, so a user who turned the sound off is not dinged by the
                        // notification that lands at the very moment the in-app sound was suppressed.
                        sound: interactor.workoutSettings.restTimerPlaySound,
                        badge: nil
                    )
                    try await interactor.schedulePushNotification(delegate: delegate)
                } catch {
                    // Silently fail - notification is nice to have but not critical
                }
            }
        }
        #endif
    }
}
