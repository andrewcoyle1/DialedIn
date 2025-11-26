//
//  WorkoutTrackerViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import HealthKit

/// Interactor protocol for handling all interactions between the Workout Tracker view model
/// and data/services, supporting HealthKit session handling, local persistence, notifications,
/// user event tracking, rest timing, preferences, and history management.
protocol WorkoutTrackerInteractor {

    // MARK: - User and Session Properties

    /// The current logged-in user, or nil if not available.
    var currentUser: UserModel? { get }
    /// The current rest end time for the active session, if any.
    var restEndTime: Date? { get }
    /// The current active workout session, if any.
    var activeSession: WorkoutSessionModel? { get }

    // MARK: - Workout Session Configuration & Lifecycle

    /// Set the configuration for a HealthKit workout session.
    func setWorkoutConfiguration(
        activityType: HKWorkoutActivityType,
        location: HKWorkoutSessionLocationType
    )

    /// Start a new workout with the given session model.
    func startWorkout(workout: WorkoutSessionModel)

    /// Retrieve a local workout session by its unique identifier.
    func getLocalWorkoutSession(id: String) throws -> WorkoutSessionModel

    /// Retrieve the currently active local workout session, if any.
    func getActiveLocalWorkoutSession() throws -> WorkoutSessionModel?

    /// Create a new workout session and store it locally.
    func createWorkoutSession(session: WorkoutSessionModel) async throws

    /// Mark a local workout session as ended at the given date.
    func endLocalWorkoutSession(id: String, at endedAt: Date) throws

    /// End a workout session and optionally mark it as completed if scheduled.
    func endActiveSession(markScheduledComplete: Bool) async

    /// End a remote (possibly HealthKit) workout session asynchronously at provided date.
    func endWorkoutSession(id: String, at endedAt: Date) async throws

    /// End the current workout and persist/close resources as needed.
    func endWorkout()

    /// Delete a local workout session by its identifier.
    func deleteLocalWorkoutSession(id: String) throws

    /// Update a local workout session with new values.
    func updateLocalWorkoutSession(session: WorkoutSessionModel) throws

    /// Set a local session as the current active one, passing nil to clear.
    func setActiveLocalWorkoutSession(_ session: WorkoutSessionModel?) throws

    /// Minimize the active workout session, e.g., background the activity in the UI.
    func minimizeActiveSession()

    // MARK: - Live Activity & Status Updates

    /// Ensure the associated live activity for a workout is continued or started.
    func ensureLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String?
    )

    /// End any running live activity for the provided workout session.
    func endLiveActivity(
        session: WorkoutSessionModel,
        isCompleted: Bool,
        statusMessage: String?
    )

    // Update live activity status and metrics for widgets/external presentation.
    // swiftlint:disable:next function_parameter_count
    func updateLiveActivity(
        session: WorkoutSessionModel,
        isActive: Bool,
        currentExerciseIndex: Int,
        restEndsAt: Date?,
        statusMessage: String?,
        totalVolumeKg: Double?,
        elapsedTime: TimeInterval?
    )

    // MARK: - User Preferences

    /// Get the exercise unit preference (weight, distance, etc.) for a template.
    func getPreference(templateId: String) -> ExerciseUnitPreference

    /// Set user's preferred weight unit for a particular exercise template.
    func setWeightUnit(_ unit: ExerciseWeightUnit, for templateId: String)

    /// Set user's preferred distance unit for a particular exercise template.
    func setDistanceUnit(_ unit: ExerciseDistanceUnit, for templateId: String)

    // MARK: - Workout History

    /// Lookup the last completed session for a given template and author, if present.
    func getLastCompletedSessionForTemplate(
        templateId: String,
        authorId: String
    ) async throws -> WorkoutSessionModel?

    /// Add a workout set result or data point to the local exercise history.
    func addLocalExerciseHistory(entry: ExerciseHistoryEntryModel) throws

    /// Persist a new history entry to remote or cloud store.
    func createExerciseHistory(entry: ExerciseHistoryEntryModel) async throws

    // MARK: - Rest & Notifications

    /// Start a rest timer for the specified duration in seconds,
    /// associated with the current session/exercise state.
    func startRest(
        durationSeconds: Int,
        session: WorkoutSessionModel,
        currentExerciseIndex: Int
    )

    /// Cancel any running rest timer.
    func cancelRest()

    /// Schedule a push notification at a future date.
    func schedulePushNotification(
        identifier: String,
        title: String,
        body: String,
        date: Date
    ) async throws

    /// Remove any pending notifications matching given identifiers.
    func removePendingNotifications(withIdentifiers identifiers: [String]) async

    // MARK: - Analytics & Event Logging

    /// Track an analytics or custom event with optional parameters.
    func trackEvent(
        eventName: String,
        parameters: [String: Any]?,
        type: LogType
    )
}

extension CoreInteractor: WorkoutTrackerInteractor { }

@MainActor
protocol WorkoutTrackerRouter {
    func showDevSettingsView()
    func showAddExercisesView(delegate: AddExerciseModalViewDelegate)
    func showWorkoutNotesView(delegate: WorkoutNotesViewDelegate)
}

extension CoreRouter: WorkoutTrackerRouter { }

@Observable
@MainActor
class WorkoutTrackerViewModel {

    let interactor: WorkoutTrackerInteractor
    private let router: WorkoutTrackerRouter

    // MARK: - State Properties

    var pendingSelectedTemplates: [ExerciseTemplateModel] = []

    var showingWorkoutNotes = false
    var showingAddExercise = false
    var editMode: EditMode = .inactive
    var isRestPickerOpen: Bool = false
    
    var workoutSession: WorkoutSessionModel?
    var startTime: Date = Date()
    var elapsedTime: TimeInterval = 0
    var isActive = true
    
    var expandedExerciseIds: Set<String> = []
    var workoutNotes = ""
    var currentExerciseIndex = 0
    
    var exerciseUnitPreferences: [String: ExerciseUnitPreference] = [:]
    var previousWorkoutSession: WorkoutSessionModel?
    
    var restDurationSeconds: Int = 90
    var restBeforeSetIdToSec: [String: Int] = [:]
    
    var showAlert: AnyAppAlert?
    
    var restPickerTargetSetId: String?
    var restPickerSeconds: Int?
    var restPickerMinutesSelection: Int = 0
    var restPickerSecondsSelection: Int = 0
    
    // Internal timers
    var widgetSyncTimer: Timer?
    
    // Notification identifier for rest timer
    private let restTimerNotificationId = "workout-rest-timer"
    
    var restEndTime: Date? {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        return interactor.restEndTime
        #else
        return nil
        #endif
    }
    
    // MARK: - Initialization
    
    init(
        interactor: WorkoutTrackerInteractor,
        router: WorkoutTrackerRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadWorkoutSession(_ workoutSession: WorkoutSessionModel) {
        self.workoutSession = workoutSession
        self.workoutNotes = workoutSession.notes ?? ""
        self.startTime = workoutSession.dateCreated
        // Refresh from local storage to ensure latest persisted changes are loaded
        buildView()
    }
    
    // MARK: - Computed Properties
    
    var elapsedTimeString: String {
        let elapsed = Date().timeIntervalSince(startTime)
        let hours = Int(elapsed) / 3600
        let minutes = Int(elapsed) / 60 % 60
        let seconds = Int(elapsed) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var isRestActive: Bool {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        guard let end = interactor.restEndTime else { return false }
        return Date() < end
        #else
        return false
        #endif
    }
    
    var completedSetsCount: Int {
        guard let workoutSession = workoutSession else { return 0 }
        return workoutSession.exercises.flatMap { $0.sets }.filter { $0.completedAt != nil }.count
    }
    
    var totalSetsCount: Int {
        guard let workoutSession = workoutSession else { return 0 }
        return workoutSession.exercises.flatMap { $0.sets }.count
    }
    
    var formattedVolume: String {
        let totalVolume = computeTotalVolumeKg()
        return String(format: "%.0f kg", totalVolume)
    }
    
    // MARK: - Lifecycle
    
    func onAppear() async {
        guard let workoutSession = workoutSession else { return }
        buildView()
        loadUnitPreferences()
        startWidgetSyncTimer()
        
        // Ensure HealthKit authorization before starting HK session
        let healthKitManager = HealthKitManager()
        if healthKitManager.canRequestAuthorisation() && healthKitManager.needsAuthorisationForRequiredTypes() {
            do {
                try await healthKitManager.requestAuthorisation()
            } catch {
                print("HealthKit authorization failed: \(error)")
            }
        }
        
        // Verify workout write permission before starting
        guard !HealthKitService().needsAuthorisationForRequiredTypes() else {
            print("Skipping HKWorkoutSession start: missing HealthKit authorization")
            return
        }
        
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Configure and start HK session for strength training
        print("📱 WorkoutTrackerViewModel: Configuring HK session for strength training")
        interactor.setWorkoutConfiguration(activityType: .traditionalStrengthTraining, location: .indoor)
        print("📱 WorkoutTrackerViewModel: About to call hkWorkoutManager.startWorkout()")
        interactor.startWorkout(workout: workoutSession)
        print("📱 WorkoutTrackerViewModel: hkWorkoutManager.startWorkout() completed")
        #endif
    }
    
    func onScenePhaseChange(oldPhase: ScenePhase, newPhase: ScenePhase) {
        if newPhase == .active && oldPhase == .background {
            print("📱 App returned to foreground, syncing widget completions and refreshing view")
            syncPendingSetCompletionFromWidget()
            buildView()
        }
    }
    
    func buildView() {
        guard var workoutSession = workoutSession else { return }
        // Refresh from local active session to ensure persisted edits are loaded
        if let latest = try? interactor.getLocalWorkoutSession(id: workoutSession.id) {
            self.workoutSession = latest
            workoutNotes = latest.notes ?? ""
            workoutSession = latest
        } else if let activeOpt = try? interactor.getActiveLocalWorkoutSession() {
            if activeOpt.id == workoutSession.id {
                self.workoutSession = activeOpt
                workoutNotes = activeOpt.notes ?? ""
                workoutSession = activeOpt
            }
        }
        // Ensure start time comes from the session creation time
        startTime = workoutSession.dateCreated
        // Ensure current exercise points to the first incomplete item
        syncCurrentExerciseIndexToFirstIncomplete(in: workoutSession.exercises)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Ensure an existing Live Activity is reused, otherwise start one
        interactor.ensureLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil
        )
        #endif

        // Expand first incomplete exercise by default (fallback to first if all complete)
        if let idx = firstIncompleteExerciseIndex(in: workoutSession.exercises) {
            expandedExerciseIds.insert(workoutSession.exercises[idx].id)
        } else if let firstExercise = workoutSession.exercises.first {
            expandedExerciseIds.insert(firstExercise.id)
        }
        
        // Check for pending widget completions that happened while backgrounded
        syncPendingSetCompletionFromWidget()
    }
    
    // MARK: - Unit Preferences
    
    func loadUnitPreferences() {
        guard let workoutSession = workoutSession else { return }
        // Load unit preferences for all exercises in the workout
        for exercise in workoutSession.exercises {
            let preference = interactor.getPreference(templateId: exercise.templateId)
            exerciseUnitPreferences[exercise.templateId] = preference
        }
        
        // Load previous workout session for "Prev" column
        loadPreviousWorkoutSession()
    }
    
    func updateWeightUnit(_ unit: ExerciseWeightUnit, for templateId: String) {
        interactor.setWeightUnit(unit, for: templateId)
        // Update local cache
        if var preference = exerciseUnitPreferences[templateId] {
            preference.weightUnit = unit
            exerciseUnitPreferences[templateId] = preference
        } else {
            exerciseUnitPreferences[templateId] = interactor.getPreference(templateId: templateId)
        }
    }
    
    func updateDistanceUnit(_ unit: ExerciseDistanceUnit, for templateId: String) {
        interactor.setDistanceUnit(unit, for: templateId)
        // Update local cache
        if var preference = exerciseUnitPreferences[templateId] {
            preference.distanceUnit = unit
            exerciseUnitPreferences[templateId] = preference
        } else {
            exerciseUnitPreferences[templateId] = interactor.getPreference(templateId: templateId)
        }
    }
    
    // MARK: - Previous Values
    
    func loadPreviousWorkoutSession() {
        guard let workoutSession = workoutSession else {
            previousWorkoutSession = nil
            return
        }
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
                    authorId: authorId
                )
            } catch {
                print("Failed to load previous workout session: \(error)")
                previousWorkoutSession = nil
            }
        }
    }
    
    func buildPreviousLookup(for exercise: WorkoutExerciseModel) -> [Int: WorkoutSetModel] {
        guard let prevSession = previousWorkoutSession else { return [:] }
        
        // Find matching exercise by templateId
        guard let prevExercise = prevSession.exercises.first(where: { $0.templateId == exercise.templateId }) else {
            return [:]
        }
        
        // Map sets by index
        return Dictionary(uniqueKeysWithValues: prevExercise.sets.map { ($0.index, $0) })
    }
    
    // MARK: - Workout Actions
    
    func discardWorkout(onDismiss: @escaping () -> Void) {
        guard let workoutSession = workoutSession else {
            onDismiss()
            return
        }
        stopWidgetSyncTimer()
        Task {
            do {
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                // End HK session first
                interactor.endWorkout()
                #endif
                
                // Cancel any pending rest timer notifications
                await interactor.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
                
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                // End live activity with immediate dismissal for discarded workouts
                interactor.endLiveActivity(session: workoutSession, isCompleted: false, statusMessage: "Workout Discarded")
                #endif
                
                try interactor.deleteLocalWorkoutSession(id: workoutSession.id)
                // Don't mark scheduled workout as complete when discarding
                await interactor.endActiveSession(markScheduledComplete: false)
                await MainActor.run {
                    onDismiss()
                }
            } catch {
                await MainActor.run {
                    showAlert = AnyAppAlert(
                        title: "Failed to discard workout",
                        subtitle: error.localizedDescription
                    )
                }
            }
        }
    }
    
    func finishWorkout(onDismiss: @escaping () -> Void) {
        guard var workoutSession = workoutSession else {
            onDismiss()
            return
        }
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
                await interactor.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
                
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
                await interactor.endActiveSession(markScheduledComplete: true)
                await MainActor.run {
                    onDismiss()
                }
            } catch {
                await MainActor.run {
                    showAlert = AnyAppAlert(title: "Failed to finish workout", subtitle: error.localizedDescription)
                }
            }
        }
    }
    
    func updateWorkoutNotes() {
        guard var workoutSession = workoutSession else { return }
        workoutSession.notes = workoutNotes.isEmpty ? nil : workoutNotes
        self.workoutSession = workoutSession
        saveWorkoutProgress()
    }
    
    func updateExerciseNotes(_ notes: String, for exerciseId: String) {
        guard var workoutSession = workoutSession else { return }
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].notes = notes.isEmpty ? nil : notes
        workoutSession.updateExercises(updatedExercises)
        self.workoutSession = workoutSession
        saveWorkoutProgress()
    }
    
    func minimizeSession(onDismiss: @escaping () -> Void) {
        interactor.minimizeActiveSession()
        onDismiss()
    }
    
    // MARK: - Rest Timer
    
    func startRestTimer(durationSeconds: Int = 0) {
        guard let workoutSession = workoutSession else { return }
        let duration = durationSeconds > 0 ? durationSeconds : restDurationSeconds
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.startRest(durationSeconds: duration, session: workoutSession, currentExerciseIndex: currentExerciseIndex)
        
        // Schedule local notification for when rest is complete
        if let endTime = interactor.restEndTime {
            Task {
                do {
                    try await interactor.schedulePushNotification(
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
    
    func cancelRestTimer() {
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Cancel in manager (will also update Live Activity)
        interactor.cancelRest()
        #endif
        
        // Cancel the pending rest timer notification
        Task {
            await interactor.removePendingNotifications(withIdentifiers: [restTimerNotificationId])
        }
    }
    
    func saveRestPickerValue() {
        let seconds = (restPickerMinutesSelection * 60) + restPickerSecondsSelection
        if let setId = restPickerTargetSetId {
            restBeforeSetIdToSec[setId] = seconds
        }
    }
    
    func openRestPicker(for setId: String, currentValue: Int?) {
        restPickerTargetSetId = setId
        restPickerSeconds = currentValue
        let total = currentValue ?? restDurationSeconds
        restPickerMinutesSelection = max(0, total / 60)
        restPickerSecondsSelection = max(0, total % 60)
    }
    
    func updateRestBeforeSet(setId: String, value: Int?) {
        if let value = value {
            restBeforeSetIdToSec[setId] = value
        } else {
            restBeforeSetIdToSec.removeValue(forKey: setId)
        }
    }
    
    func getRestBeforeSet(setId: String) -> Int? {
        restBeforeSetIdToSec[setId]
    }
    
    // MARK: - Persistence
    
    func saveWorkoutProgress() {
        guard let workoutSession = workoutSession else { return }
        Task {
            do {
                try interactor.updateLocalWorkoutSession(session: workoutSession)
                // Keep active session storage in sync so minimize/restore loads latest edits
                try? interactor.setActiveLocalWorkoutSession(workoutSession)
            } catch {
                await MainActor.run {
                    showAlert = AnyAppAlert(title: "Failed to save progress", subtitle: error.localizedDescription)
                }
            }
        }
    }
    
    private func createExerciseHistoryEntries(performedAt: Date) async throws {
        guard let workoutSession = workoutSession else {
            throw NSError(domain: "WorkoutTrackerViewModel", code: 400, userInfo: [NSLocalizedDescriptionKey: "No workout session loaded"])
        }
        guard let userId = interactor.currentUser?.userId else {
            throw NSError(domain: "WorkoutTrackerViewModel", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Create exercise history entries for each exercise in the session
        for workoutExercise in workoutSession.exercises {
            let historyEntry = ExerciseHistoryEntryModel.newEntry(
                authorId: userId,
                templateId: workoutExercise.templateId,
                templateName: workoutExercise.name,
                workoutSessionId: workoutSession.id,
                workoutExerciseId: workoutExercise.id,
                performedAt: performedAt,
                notes: workoutExercise.notes,
                sets: workoutExercise.sets
            )
            
            // Save to local storage
            try interactor.addLocalExerciseHistory(entry: historyEntry)
            
            // Save to remote storage
            try await interactor.createExerciseHistory(entry: historyEntry)
        }
    }
    
    // MARK: - Helpers
    
    func computeTotalVolumeKg() -> Double {
        guard let workoutSession = workoutSession else { return 0.0 }
        return workoutSession.exercises.flatMap { $0.sets }
            .compactMap { set in
                guard let weight = set.weightKg, let reps = set.reps else { return nil }
                return weight * Double(reps)
            }
            .reduce(0.0, +)
    }
    
    private func firstIncompleteExerciseIndex(in exercises: [WorkoutExerciseModel]) -> Int? {
        exercises.firstIndex(where: { !$0.sets.isEmpty && !$0.sets.allSatisfy { $0.completedAt != nil } })
    }

    func syncCurrentExerciseIndexToFirstIncomplete(in exercises: [WorkoutExerciseModel]) {
        let oldIndex = currentExerciseIndex
        if let idx = firstIncompleteExerciseIndex(in: exercises) {
            currentExerciseIndex = idx
        } else {
            currentExerciseIndex = max(0, exercises.isEmpty ? 0 : exercises.count - 1)
        }
        if oldIndex != currentExerciseIndex {
            print("🔄 Current exercise index changed: \(oldIndex) → \(currentExerciseIndex) (reason: sync to first incomplete)")
        }
    }
    
    func applyReorderedExercises(_ updated: [WorkoutExerciseModel], movedFrom: Int?, movedTo: Int) {
        guard var workoutSession = workoutSession else { return }
        var updated = updated
        // Reindex exercises only (do not touch set indices)
        for idx in updated.indices {
            updated[idx].index = idx + 1
        }

        // Always align current exercise to top-most incomplete after reorders
        workoutSession.updateExercises(updated)
        self.workoutSession = workoutSession
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)

        saveWorkoutProgress()
    }
    
    func lastKnownRestForExercise(exerciseIndex: Int) -> Int? {
        guard let workoutSession = workoutSession else { return nil }
        guard exerciseIndex < workoutSession.exercises.count else { return nil }
        let sets = workoutSession.exercises[exerciseIndex].sets
        // Walk from last to first to find a mapping
        for set in sets.reversed() {
            if let val = restBeforeSetIdToSec[set.id] { return val }
        }
        return nil
    }
    
    func presentWorkoutNotes() {
        router.showWorkoutNotesView(
            delegate: WorkoutNotesViewDelegate(
                notes: Binding(
                    get: {
                        self.workoutNotes
                    },
                    set: { newValue in
                        self.workoutNotes = newValue
                    }
                ),
                onSave: {
                    self.updateWorkoutNotes()
                }
            )
        )
    }
    
    func presentAddExercise() {
        router.showAddExercisesView(delegate: AddExerciseModalViewDelegate(selectedExercises: Binding(
            get: { self.pendingSelectedTemplates },
            set: { self.pendingSelectedTemplates = $0 }
        )))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}
