//
//  HKWorkoutManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import Foundation
#if canImport(HealthKit) && !targetEnvironment(macCatalyst)
import HealthKit

@Observable
@MainActor
class HKWorkoutManager: NSObject {
    struct SessionStateChange {
        let newState: HKWorkoutSessionState
        let date: Date
    }
    
    private(set) var state: HKWorkoutSessionState = .notStarted
    
    var workoutConfiguration: HKWorkoutConfiguration?
    var selectedWorkout: HKWorkoutConfiguration? {
        didSet {
            guard let selectedWorkout else { return }
            
            Task {
                do {
                    workoutConfiguration = selectedWorkout
                    try await prepareWorkout()
                    metrics.supportsDistance = selectedWorkout.supportsDistance
                    metrics.supportsSpeed = selectedWorkout.supportsSpeed
                } catch {
                    print("Failed to start workout \(error)")
                    state = .notStarted
                }
            }
        }
    }
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    var isLiveActivityActive: Bool = false
    var timer: Timer?
    // Rest timer management for background-safe updates
    var restTimer: DispatchSourceTimer?
    var restEndTime: Date?
    private var isUpdatingActivity: Bool = false
    private var restStateChangedAt: Date?
    
    var workout: HKWorkout?
    var activeSessionModel: WorkoutSessionModel?
    
    // Weak reference to avoid circular dependency
    weak var workoutActivityViewModel: WorkoutActivityViewModel?

    /**
     Creates an asynchronous stream that buffers a single newest element
     and the stream's continuation to yield new elements synchronously to the stream.
     The Swift actors don't handle tasks in a first-in-first-in manner.
     Use `AsyncStream` to ensure that the app presents the latest state.
     */
    let asyncStreamTuple = AsyncStream.makeStream(of: SessionStateChange.self,
                                                  bufferingPolicy: .bufferingNewest(1))

    /**
     `HKWorkoutManager` is now dependency-injected.
     */

    /**
     Kick off a task to consume the asynchronous stream. The next value in the stream can't start processing
     until `await consumeSessionStateChange(value)` returns and the loop enters the next iteration, which serializes the asynchronous operations.
     */

    nonisolated override init() {
        super.init()
        
        // Kick off stream consumption task
        Task { @MainActor in
            for await value in self.asyncStreamTuple.stream {
                await self.consumeSessionStateChange(value)
            }
        }
    }

    func setWorkoutConfiguration(activityType: HKWorkoutActivityType, location: HKWorkoutSessionLocationType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        configuration.locationType = location

        selectedWorkout = configuration
    }

    func prepareWorkout() async throws {
        guard let configuration = workoutConfiguration else { return }

        state = .prepared
        
        session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()
        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        session?.prepare()
    }

    func startWorkout(workout: WorkoutSessionModel) {
        self.activeSessionModel = workout
        Task {
            do {
                // Start the workout session and begin data collection.
                let startDate = Date()
                session?.startActivity(with: startDate)
                state = .running
                try await builder?.beginCollection(at: startDate)

                workoutActivityViewModel?.startLiveActivity(session: workout)
                startWorkoutTimer()
            } catch {
                print("Failed to start workout \(error))")
                state = .notStarted
            }
        }
    }

    // Recover the workout for the session.
    func recoverWorkout(workout: WorkoutSessionModel, recoveredSession: HKWorkoutSession) {
        self.activeSessionModel = workout
        state = .running
        session = recoveredSession
        builder = recoveredSession.associatedWorkoutBuilder()
        session?.delegate = self
        builder?.delegate = self
        workoutConfiguration = recoveredSession.workoutConfiguration
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: recoveredSession.workoutConfiguration)

        workoutActivityViewModel?.startLiveActivity(session: workout)
        startWorkoutTimer()
    }

    // MARK: - State Control

    func pause() {
        session?.pause()
        stopTimer()
    }

    func resume() {
        session?.resume()
        startWorkoutTimer()
    }

    func togglePause() {
        switch state {
        case .running:
            pause()
        case .paused:
            resume()
        default:
            print("togglePause() called when workout isn't running or paused")
        }
    }

    func endWorkout() {
        state = .stopped
        session?.stopActivity(with: .now)
        stopTimer()
        // Ensure any pending rest is cancelled when ending workout
        cancelRest()
    }

    // MARK: - Workout Metrics
    var metrics: MetricsModel = MetricsModel(elapsedTime: 0)

    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        print("updated statistics=\(statistics)")

        guard let activityType = session?.activityType else {
            print("activityType is nil when processing statistics")
            return
        }

        if WorkoutTypes.distanceQuantityType(for: activityType) == statistics.quantityType {
            let meterUnit = HKUnit.meter()
            self.metrics.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit)
            return
        }

        if WorkoutTypes.speedQuantityType(for: activityType) == statistics.quantityType {
            let speedUnit = HKUnit.meter().unitDivided(by: HKUnit.second())
            self.metrics.speed = statistics.mostRecentQuantity()?.doubleValue(for: speedUnit)
            return
        }

        switch statistics.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            self.metrics.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
        case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
            let energyUnit = HKUnit.kilocalorie()
            self.metrics.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit)
        default:
            print("unhandled quantityType=\(statistics.quantityType) when processing statistics")
            return
        }
    }

    func resetWorkout() {
        print("reset workout data model")
        selectedWorkout = nil
        builder = nil
        session = nil
        workout = nil
        activeSessionModel = nil

        metrics = MetricsModel(elapsedTime: 0)

        stopTimer()
        cancelRest()

        state = .notStarted
    }

    private func consumeSessionStateChange(_ change: SessionStateChange) async {
        guard change.newState == .stopped, let builder else { return }

        let finishedWorkout: HKWorkout?
        do {
            try await builder.endCollection(at: change.date)
            finishedWorkout = try await builder.finishWorkout()
            self.metrics.elapsedTime = finishedWorkout?.duration ?? 0
            if let sessionModel = activeSessionModel {
                    workoutActivityViewModel?.endLiveActivity(
                    session: sessionModel,
                    isCompleted: true,
                    statusMessage: "Workout ended"
                )
            }
            session?.end()
        } catch {
            print("Error finishing workout: \(error)")
            if let sessionModel = activeSessionModel {
                    workoutActivityViewModel?.endLiveActivity(
                    session: sessionModel,
                    isCompleted: false,
                    statusMessage: "Failed to finish workout"
                )
            }
            return
        }
        workout = finishedWorkout
        state = .ended
    }

    // Starts a timer for the ongoing `workoutManager` session and updates the Live Activity.
    func startWorkoutTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task {
                await MainActor.run {
                    self.metrics.elapsedTime = self.builder?.elapsedTime ?? 0
                    
                    // Sync rest end time from shared storage (in case widget updated it)
                    self.syncRestEndTimeFromSharedStorage()
                    
                    // Don't update Live Activity from here - let WorkoutTrackerView handle it
                    // HKWorkoutManager should only update rest/elapsed time via updateRestAndActive
                    // to avoid interfering with the currentExerciseIndex managed by WorkoutTrackerView
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - HKWorkoutSessionDelegate
extension HKWorkoutManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession,
                                    didChangeTo toState: HKWorkoutSessionState,
                                    from fromState: HKWorkoutSessionState,
                                    date: Date) {
        Task { @MainActor in
            switch toState {
            case .running:
                self.state = .running
            case .paused:
                self.state = .paused
            default:
                // Fill this out as needed.
                break
            }
        }

        /**
         Yield the new state change to the asynchronous stream synchronously.
         `asynStreamTuple` is a constant, so it's nonisolated.
         */
        let sessionStateChange = SessionStateChange(newState: toState, date: date)
        asyncStreamTuple.continuation.yield(sessionStateChange)
    }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("workout session did fail with error=\(error)")
    }
}

// moved to HKWorkout+Configuration.swift

// MARK: - HKLiveWorkoutBuilderDelegate
extension HKWorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        guard let event = workoutBuilder.workoutEvents.last else {
            return
        }
        print("workout builder did collect event=\(event)")
    }

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        Task { @MainActor in
            for type in collectedTypes {
                guard let quantityType = type as? HKQuantityType else { return }

                let statistics = workoutBuilder.statistics(for: quantityType)

                // Update the published values.
                updateForStatistics(statistics)
            }
        }
    }

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didEnd workoutActivity: HKWorkoutActivity) {
        print("workout builder did end workout_activity=\(workoutActivity)")
    }
}

// MARK: - Rest Timer Management
extension HKWorkoutManager {
    /// Sync rest end time from shared storage (called by timer to pick up widget changes)
    @MainActor
    func syncRestEndTimeFromSharedStorage() {
        let sharedRestEndTime = SharedWorkoutStorage.restEndTime
        
        // Only update if there's a meaningful difference (more than 0.5 seconds)
        if let sharedTime = sharedRestEndTime, let currentTime = restEndTime {
            let difference = abs(sharedTime.timeIntervalSince(currentTime))
            if difference > 0.5 {
                restEndTime = sharedTime
                // Mark a recent change to debounce periodic refresh and push an immediate update
                restStateChangedAt = Date()
                // Reschedule the timer with new end time
                if let endTime = restEndTime {
                    scheduleRestEndTimer(endTime: endTime)
                }
                // Push an immediate Live Activity update so UI reflects changes without 1s delay
                if activeSessionModel != nil {
                    workoutActivityViewModel?.updateRestAndActive(
                        isActive: state == .running,
                        restEndsAt: restEndTime,
                        statusMessage: "Resting"
                    )
                }
            }
        } else if sharedRestEndTime == nil && restEndTime != nil {
            // Rest was cleared by widget
            restEndTime = nil
            restStateChangedAt = Date()
            // Cancel any scheduled timer
            restTimer?.cancel()
            restTimer = nil
            // Push an immediate Live Activity update to clear UI
            if activeSessionModel != nil {
                workoutActivityViewModel?.updateRestAndActive(
                    isActive: state == .running,
                    restEndsAt: nil,
                    statusMessage: nil
                )
            }
        }
    }
    
    /// Begin a rest period and schedule a background-safe update at rest end.
    @MainActor
    func startRest(durationSeconds: Int, session: WorkoutSessionModel, currentExerciseIndex: Int = 0) {
        // Cancel any existing rest to avoid multiple timers
        cancelRest()

        let duration = max(0, durationSeconds)
        restEndTime = Date().addingTimeInterval(TimeInterval(duration))
        restStateChangedAt = Date()
        
        // Write to shared storage so widget can read it
        SharedWorkoutStorage.restEndTime = restEndTime

        // Update Live Activity immediately to show Resting countdown
        workoutActivityViewModel?.updateLiveActivity(
            session: session,
            isActive: state == .running,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: "Resting",
            totalVolumeKg: nil,
            elapsedTime: metrics.elapsedTime
        )

        // Schedule timer to fire exactly at rest end, even when app is backgrounded
        if let endTime = restEndTime {
            scheduleRestEndTimer(endTime: endTime)
        }
    }

    /// Cancel any pending rest and clear countdown from Live Activity.
    @MainActor
    func cancelRest() {
        restTimer?.cancel()
        restTimer = nil
        restEndTime = nil
        restStateChangedAt = Date()
        
        // Clear from shared storage
        SharedWorkoutStorage.clearRestEndTime()

        // Update Live Activity to clear rest state (use updateRestAndActive to preserve exercise index)
        workoutActivityViewModel?.updateRestAndActive(
            isActive: state == .running,
            restEndsAt: nil,
            statusMessage: nil
        )
    }

    /// Called automatically when the scheduled rest end time is reached.
    @MainActor
    func endRest() {
        restTimer?.cancel()
        restTimer = nil
        restEndTime = nil
        restStateChangedAt = Date()
        
        // Clear from shared storage
        SharedWorkoutStorage.clearRestEndTime()

        guard activeSessionModel != nil else {
            print("⚠️ endRest called but activeSessionModel is nil")
            return
        }
        
        guard workoutActivityViewModel != nil else {
            print("⚠️ endRest called but workoutActivityViewModel is nil")
            return
        }
        
        // Update Live Activity to clear rest state (use updateRestAndActive to preserve exercise index)
        workoutActivityViewModel?.updateRestAndActive(
            isActive: state == .running,
            restEndsAt: nil,
            statusMessage: nil
        )
    }

    nonisolated private func scheduleRestEndTimer(endTime: Date) {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .utility))
        let delta = max(0, endTime.timeIntervalSinceNow)
        timer.schedule(deadline: .now() + delta)
        timer.setEventHandler { [weak self] in
            // Use Task to safely call MainActor-isolated method from background queue
            Task { @MainActor [weak self] in
                self?.endRest()
            }
        }
        timer.resume()
        
        // Store the timer reference back on MainActor
        Task { @MainActor [weak self] in
            self?.restTimer = timer
        }
    }
}
#endif
