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
    
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private(set) var state: HKWorkoutSessionState = .notStarted

    private let logger: LogManager

    private var timer: Timer?
    // Rest timer management for background-safe updates
    private var restTimer: DispatchSourceTimer?
    private(set) var restEndTime: Date?

    private var isDiscarding = false
    private var workout: HKWorkout?
    private var activeSessionModel: WorkoutSessionModel?
    
    // Weak reference to avoid circular dependency
    weak var liveActivityUpdater: LiveActivityUpdating?

    // Buffers a single newest element; ensures async operations are serialized
    // since the loop doesn't start the next iteration until consumeSessionStateChange returns.
    private let asyncStreamTuple = AsyncStream.makeStream(of: SessionStateChange.self,
                                                          bufferingPolicy: .bufferingNewest(1))

    init(logger: LogManager) {
        self.logger = logger
        super.init()
        // Capture stream locally so the Task does not capture `self` before NSObject init completes.
        // The next value in the stream won't start processing until `consumeSessionStateChange` returns,
        // which serializes asynchronous operations.
        let stream = asyncStreamTuple.stream
        Task { [weak self] in
            for await value in stream {
                await self?.consumeSessionStateChange(value)
            }
        }
    }

    func setWorkoutConfiguration(
        activityType: HKWorkoutActivityType,
        location: HKWorkoutSessionLocationType
    ) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activityType
        configuration.locationType = location

        Task {
            do {
                try await prepareWorkout(configuration: configuration)
                metrics.supportsDistance = configuration.supportsDistance
                metrics.supportsSpeed = configuration.supportsSpeed
            } catch {
                logger.trackEvent(event: Event.startWorkoutFail(error: error))
                state = .notStarted
            }
        }
    }

    private func prepareWorkout(configuration: HKWorkoutConfiguration) async throws {
        state = .prepared

        session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()
        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        session?.prepare()
    }
    
    func startWorkout(workout: WorkoutSessionModel) {
        logger.trackEvent(event: Event.startWorkoutStart)
        activeSessionModel = workout
        Task {
            do {
                let startDate = Date()
                session?.startActivity(with: startDate)
                try await builder?.beginCollection(at: startDate)
                startWorkoutTimer()
                logger.trackEvent(event: Event.startWorkoutSuccess)
            } catch {
                logger.trackEvent(event: Event.startWorkoutFail(error: error))
                state = .notStarted
            }
        }
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
            logger.trackEvent(event: Event.togglePauseInvalidState)
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
        guard let statistics else { return }

        guard let activityType = session?.activityType else {
            logger.trackEvent(event: Event.activityTypeNil)
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
            logger.trackEvent(event: Event.quantityTypeUnhandled)
        }
    }

    func discardWorkout() {
        logger.trackEvent(event: Event.discardWorkout)
        isDiscarding = true
        session?.stopActivity(with: .now)

        builder = nil
        workout = nil
        activeSessionModel = nil

        metrics = MetricsModel(elapsedTime: 0)

        stopTimer()
        cancelRest()
    }

    private func consumeSessionStateChange(_ change: SessionStateChange) async {
        guard change.newState == .stopped else { return }

        if isDiscarding {
            if #available(iOS 17, *) {
                builder?.discardWorkout()
            }
            session?.end()
            isDiscarding = false
            builder = nil
            session = nil
            state = .notStarted
            return
        }

        guard let builder else { return }

        let finishedWorkout: HKWorkout?
        logger.trackEvent(event: Event.finishWorkoutStart)

        do {
            try await builder.endCollection(at: change.date)
            finishedWorkout = try await builder.finishWorkout()
            self.metrics.elapsedTime = finishedWorkout?.duration ?? 0
            logger.trackEvent(event: Event.finishWorkoutSuccess)

            if let sessionModel = activeSessionModel {
                liveActivityUpdater?.endLiveActivity(
                    session: sessionModel,
                    isCompleted: true,
                    statusMessage: "Workout ended"
                )
            }
            session?.end()
        } catch {
            logger.trackEvent(event: Event.finishWorkoutFail(error: error))
            if let sessionModel = activeSessionModel {
                liveActivityUpdater?.endLiveActivity(
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
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.metrics.elapsedTime = self.builder?.elapsedTime ?? 0
                self.syncRestEndTimeFromSharedStorage()
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
        Task { @MainActor [weak self] in
            self?.logger.trackEvent(event: Event.workoutSessionFailed(error: error))
        }
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension HKWorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) { }

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

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didEnd workoutActivity: HKWorkoutActivity) { }
}

// MARK: - Rest Timer Management
extension HKWorkoutManager {
    /// Sync rest end time from shared storage (called by timer to pick up widget changes)
    func syncRestEndTimeFromSharedStorage() {
        let sharedRestEndTime = SharedWorkoutStorage.restEndTime
        
        // Only update if there's a meaningful difference (more than 0.5 seconds)
        if let sharedTime = sharedRestEndTime, let currentTime = restEndTime {
            let difference = abs(sharedTime.timeIntervalSince(currentTime))
            if difference > 0.5 {
                restEndTime = sharedTime
                // Reschedule the timer with new end time
                if let endTime = restEndTime {
                    scheduleRestEndTimer(endTime: endTime)
                }
                // Push an immediate Live Activity update so UI reflects changes without 1s delay
                if activeSessionModel != nil {
                    liveActivityUpdater?.updateRestAndActive(
                        isActive: state == .running,
                        restEndsAt: restEndTime,
                        statusMessage: "Resting"
                    )
                }
            }
        } else if sharedRestEndTime == nil && restEndTime != nil {
            // Rest was cleared by widget
            restEndTime = nil
            // Cancel any scheduled timer
            restTimer?.cancel()
            restTimer = nil
            // Push an immediate Live Activity update to clear UI
            if activeSessionModel != nil {
                liveActivityUpdater?.updateRestAndActive(
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

        // Write to shared storage so widget can read it
        SharedWorkoutStorage.restEndTime = restEndTime

        // Update Live Activity immediately to show Resting countdown
        liveActivityUpdater?.updateLiveActivity(params: LiveActivityUpdateParams(
            session: session,
            isActive: state == .running,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: restEndTime,
            statusMessage: "Resting",
            totalVolumeKg: nil,
            elapsedTime: metrics.elapsedTime
        ))

        // Schedule timer to fire exactly at rest end, even when app is backgrounded
        if let endTime = restEndTime {
            scheduleRestEndTimer(endTime: endTime)
        }
    }

    /// Cancel any pending rest and clear countdown from Live Activity.
    func cancelRest() {
        restTimer?.cancel()
        restTimer = nil
        restEndTime = nil

        // Clear from shared storage
        SharedWorkoutStorage.clearRestEndTime()

        // Update Live Activity to clear rest state (use updateRestAndActive to preserve exercise index)
        liveActivityUpdater?.updateRestAndActive(
            isActive: state == .running,
            restEndsAt: nil,
            statusMessage: nil
        )
    }

    /// Called automatically when the scheduled rest end time is reached.
    func endRest() {
        restTimer?.cancel()
        restTimer = nil
        restEndTime = nil

        // Clear from shared storage
        SharedWorkoutStorage.clearRestEndTime()

        guard activeSessionModel != nil else {
            logger.trackEvent(event: Event.endRestNoSession)
            return
        }

        guard liveActivityUpdater != nil else {
            logger.trackEvent(event: Event.endRestNoUpdater)
            return
        }
        
        // Update Live Activity to clear rest state (use updateRestAndActive to preserve exercise index)
        liveActivityUpdater?.updateRestAndActive(
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

extension HKWorkoutManager {
    enum Event: LoggableEvent {
        case startWorkoutStart
        case startWorkoutSuccess
        case startWorkoutFail(error: Error)
        case finishWorkoutStart
        case finishWorkoutSuccess
        case finishWorkoutFail(error: Error)
        case discardWorkout
        case togglePauseInvalidState
        case activityTypeNil
        case quantityTypeUnhandled
        case workoutSessionFailed(error: Error)
        case endRestNoSession
        case endRestNoUpdater

        var eventName: String {
            switch self {
            case .startWorkoutStart:        return "HKWorkoutMan_StartWorkout_Start"
            case .startWorkoutSuccess:      return "HKWorkoutMan_StartWorkout_Success"
            case .startWorkoutFail:         return "HKWorkoutMan_StartWorkout_Fail"
            case .finishWorkoutStart:       return "HKWorkoutMan_FinishWorkout_Start"
            case .finishWorkoutSuccess:     return "HKWorkoutMan_FinishWorkout_Success"
            case .finishWorkoutFail:        return "HKWorkoutMan_FinishWorkout_Fail"
            case .discardWorkout:           return "HKWorkoutMan_DiscardWorkout"
            case .togglePauseInvalidState:  return "HKWorkoutMan_TogglePause_InvalidState"
            case .activityTypeNil:          return "HKWorkoutMan_ActivityType_Nil"
            case .quantityTypeUnhandled:    return "HKWorkoutMan_QuantityType_Unhandled"
            case .workoutSessionFailed:     return "HKWorkoutMan_Session_Failed"
            case .endRestNoSession:         return "HKWorkoutMan_EndRest_NoSession"
            case .endRestNoUpdater:         return "HKWorkoutMan_EndRest_NoUpdater"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .startWorkoutFail(let error), .finishWorkoutFail(let error), .workoutSessionFailed(let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .startWorkoutFail, .finishWorkoutFail, .workoutSessionFailed:
                return .severe
            case .togglePauseInvalidState, .activityTypeNil, .quantityTypeUnhandled, .endRestNoSession, .endRestNoUpdater:
                return .warning
            default:
                return .analytic
            }
        }
    }
}

extension CoreInteractor {
    // MARK: HKWorkoutManager

    func setWorkoutConfiguration(activityType: HKWorkoutActivityType, location: HKWorkoutSessionLocationType) {
        hkWorkoutManager.setWorkoutConfiguration(activityType: activityType, location: location)
    }

    func startWorkout(workout: WorkoutSessionModel) {
        hkWorkoutManager.startWorkout(workout: workout)
    }

    func endWorkout() {
        hkWorkoutManager.endWorkout()
    }

    func discardWorkout() {
        hkWorkoutManager.discardWorkout()
    }

    // Rest Timer Management
    @MainActor
    func syncRestEndTimeFromSharedStorage() {
        hkWorkoutManager.syncRestEndTimeFromSharedStorage()
    }

    /// Begin a rest period and schedule a background-safe update at rest end.
    @MainActor
    func startRest(durationSeconds: Int, session: WorkoutSessionModel, currentExerciseIndex: Int = 0) {
        hkWorkoutManager.startRest(durationSeconds: durationSeconds, session: session, currentExerciseIndex: currentExerciseIndex)
    }

    /// Cancel any pending rest and clear countdown from Live Activity.
    @MainActor
    func cancelRest() {
        hkWorkoutManager.cancelRest()
    }
}
#endif

private struct SessionStateChange {
    let newState: HKWorkoutSessionState
    let date: Date
}
