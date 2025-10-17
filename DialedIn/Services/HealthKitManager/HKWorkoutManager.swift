//
//  HKWorkoutManager.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import Foundation
#if canImport(HealthKit)
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
    // Rest state tracking for background-safe updates (staleDate-driven)
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
                    success: true,
                    statusMessage: "Workout ended"
                )
            }
            session?.end()
        } catch {
            print("Error finishing workout: \(error)")
            if let sessionModel = activeSessionModel {
                    workoutActivityViewModel?.endLiveActivity(
                    session: sessionModel,
                    success: false,
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
                    // If a rest is active and has passed, end it (no background timer needed)
                    if let end = self.restEndTime, Date() >= end {
                        self.endRest()
                        return
                    }
                    // For frequent ticks, avoid recomputing counts/volume from session model
                    // Preserve counts by updating only active/rest fields
                    // Debounce immediately after a rest state change to ensure that
                    // the explicit rest update reaches the Live Activity first.
                    if let changedAt = self.restStateChangedAt, Date().timeIntervalSince(changedAt) < 0.5 {
                        return
                    }
                    if !self.isUpdatingActivity {
                        self.isUpdatingActivity = true
                        self.workoutActivityViewModel?.updateRestAndActive(
                            isActive: self.state == .running,
                            restEndsAt: self.restEndTime,
                            statusMessage: nil
                        )
                        self.isUpdatingActivity = false
                    }
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
    /// Begin a rest period and schedule a background-safe update at rest end.
    @MainActor
    func startRest(durationSeconds: Int, session: WorkoutSessionModel, currentExerciseIndex: Int = 0) {
        // Cancel any existing rest to avoid multiple timers
        cancelRest()

        let duration = max(0, durationSeconds)
        restEndTime = Date().addingTimeInterval(TimeInterval(duration))
        restStateChangedAt = Date()

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

        // Do not schedule a background timer. We rely on Live Activity staleDate and
        // clear rest on the next foreground tick when the end time passes.
    }

    /// Cancel any pending rest and clear countdown from Live Activity.
    @MainActor
    func cancelRest() {
        restEndTime = nil
        restStateChangedAt = Date()

        guard let sessionModel = activeSessionModel else { return }
        workoutActivityViewModel?.updateLiveActivity(
            session: sessionModel,
            isActive: state == .running,
            currentExerciseIndex: 0,
            restEndsAt: nil,
            statusMessage: nil,
            totalVolumeKg: nil,
            elapsedTime: metrics.elapsedTime
        )
    }

    /// Called automatically when the scheduled rest end time is reached.
    @MainActor
    func endRest() {
        restEndTime = nil
        restStateChangedAt = Date()

        guard let sessionModel = activeSessionModel else { return }
        workoutActivityViewModel?.updateLiveActivity(
            session: sessionModel,
            isActive: state == .running,
            currentExerciseIndex: 0,
            restEndsAt: nil,
            statusMessage: nil,
            totalVolumeKg: nil,
            elapsedTime: metrics.elapsedTime
        )
    }
}
#endif
