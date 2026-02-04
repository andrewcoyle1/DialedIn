//
//  WorkoutTrackerPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import HealthKit

@Observable
@MainActor
// swiftlint:disable:next type_body_length
class WorkoutTrackerPresenter {

    private let interactor: WorkoutTrackerInteractor
    private let router: WorkoutTrackerRouter

    // MARK: - State Properties
    var workoutSession: WorkoutSessionModel
    var restDurationSeconds: Int = 90
    var restBeforeSetIdToSec: [String: Int] = [:]
    var restPickerTargetSetId: String?
    var restPickerMinutesSelection: Int = 0
    var restPickerSecondsSelection: Int = 0

    var pendingSelectedTemplates: [ExerciseModel] = []

    var editMode: EditMode = .inactive
    
    var startTime: Date = Date()
    var elapsedTime: TimeInterval = 0
    var isActive = true
    
    var expandedExerciseIds: Set<String> = []
    var workoutNotes = ""
    var currentExerciseIndex = 0
    
    var previousWorkoutSession: WorkoutSessionModel?
    var exerciseUnitPreferences: [String: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)] = [:]

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
    
    var exercisesCount: String {
        "\(workoutSession.exercises.count) exercises"
    }
    
    var exerciseFraction: String {
        "\(currentExerciseIndex + 1)/\(workoutSession.exercises.count)"
    }
    
    var completedSetsFraction: String {
        "\(completedSetsCount)/\(totalSetsCount)"
    }
    
    var favouriteGymProfile: GymProfileModel? {
        interactor.favouriteGymProfile
    }
    
    // MARK: - Initialization
    
    init(
        interactor: WorkoutTrackerInteractor,
        router: WorkoutTrackerRouter
    ) {
        self.interactor = interactor
        self.router = router
        
        if let session = interactor.activeSession {
            self.workoutSession = session
        } else {
            self.workoutSession = WorkoutSessionModel(authorId: UUID().uuidString, template: .mock)
        }
    }
    
    func loadWorkoutSession(_ workoutSessionId: String) async {
        do {
            self.workoutSession = try interactor.getLocalWorkoutSession(id: workoutSessionId)
        } catch let localError {
            print("⚠️ Failed to load workout session locally: \(localError.localizedDescription)")
            do {
                self.workoutSession = try await interactor.getWorkoutSession(id: workoutSessionId)
            } catch let remoteError {
                print("⚠️ Failed to load workout session remotely: \(remoteError.localizedDescription)")
                // Only show error if we don't already have a valid session from activeSession
                if workoutSession.id != workoutSessionId {
                    router.showSimpleAlert(title: "Failed to load workout session", subtitle: "Please try again")
                }
            }
        }
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
        return workoutSession.exercises.flatMap { $0.sets }.filter { $0.completedAt != nil }.count
    }
    
    var totalSetsCount: Int {
        return workoutSession.exercises.flatMap { $0.sets }.count
    }
    
    var formattedVolume: String {
        let totalVolume = computeTotalVolumeKg()
        return String(format: "%.0f kg", totalVolume)
    }
    
    // MARK: - Lifecycle
    @MainActor
    deinit {
        stopWidgetSyncTimer()
    }
    
    func onAppear() async {
        print("📥 WorkoutTrackerPresenter.onAppear() for session id=\(workoutSession.id)")
        buildView()
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
        // Avoid starting the same HK workout session multiple times for this workout.
        if SharedWorkoutStorage.hkStartedSessionId == workoutSession.id {
            print("⏭️ Skipping HK start; already started for session id=\(workoutSession.id)")
            return
        }
        
        let currentHKState = interactor.workoutSessionState
        print("📊 HK state in onAppear for session \(workoutSession.id): \(String(describing: currentHKState)))")
        // Configure and start HK session for strength training
        print("📱 WorkoutTrackerPresenter: Configuring HK session for strength training")
        interactor.setWorkoutConfiguration(activityType: .traditionalStrengthTraining, location: .indoor)
        print("📱 WorkoutTrackerPresenter: About to call hkWorkoutManager.startWorkout()")
        interactor.startWorkout(workout: workoutSession)
        print("📱 WorkoutTrackerPresenter: hkWorkoutManager.startWorkout() completed")
        SharedWorkoutStorage.hkStartedSessionId = workoutSession.id
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
        print("🏗️ WorkoutTrackerPresenter.buildView() starting for session id=\(workoutSession.id)")
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
        print("✅ WorkoutTrackerPresenter.buildView() completed; exercises=\(workoutSession.exercises.count), currentExerciseIndex=\(currentExerciseIndex)")
    }
            
    // MARK: - Previous Values
    
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
                    authorId: authorId
                )
            } catch {
                print("Failed to load previous workout session: \(error)")
                previousWorkoutSession = nil
            }
        }
    }

    func getUnitPreference(for templateId: String) -> (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit) {
        if let cached = exerciseUnitPreferences[templateId] {
            return cached
        }
        let preference = interactor.getPreference(templateId: templateId)
        let result = (weightUnit: preference.weightUnit, distanceUnit: preference.distanceUnit)
        exerciseUnitPreferences[templateId] = result
        return result
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
    
    func discardWorkout() {
        stopWidgetSyncTimer()
        Task {
            do {
                try? await Task.sleep(for: .seconds(1))
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
                SharedWorkoutStorage.clearHKStartedSessionId()
                await interactor.endActiveSession(markScheduledComplete: false)
                router.dismissScreen()

            } catch {
                await MainActor.run {
                    self.router.showSimpleAlert(
                        title: "Failed to discard workout",
                        subtitle: error.localizedDescription
                    )
                }
            }
        }

    }

    func onDiscardWorkoutPressed() {
        router.showAlert(
            title: "End Workout?",
            subtitle: "Are you sure you want to discard this workout?"
        ) {
            AnyView(
                VStack {
                    Button("Cancel", role: .cancel) {
                    }
                    Button("Discard", role: .destructive) {
                        self.discardWorkout()
                    }
                }
            )
        }
    }

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
            
    func minimizeSession() {
        stopWidgetSyncTimer()
        router.dismissScreen()
    }
    
    // MARK: - Rest Timer
    
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
            
    // MARK: - Persistence
    
    func saveWorkoutProgress() {
        Task {
            do {
                try interactor.updateLocalWorkoutSession(session: workoutSession)
                // Keep active session storage in sync so minimize/restore loads latest edits
                try? interactor.setActiveLocalWorkoutSession(workoutSession)
            } catch {
                await MainActor.run {
                    self.router.showSimpleAlert(title: "Failed to save progress", subtitle: error.localizedDescription)
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
        
    func presentWorkoutNotes() {
        router.showWorkoutNotesView(
            delegate: WorkoutNotesDelegate(
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
    
    private func updateWorkoutNotes() {
        workoutSession.notes = workoutNotes.isEmpty ? nil : workoutNotes
        self.workoutSession = workoutSession
        saveWorkoutProgress()
    }
    
    func presentAddExercise() {
        router.showExercisePickerView(
            delegate: ExercisePickerDelegate(
                selectedExercises: Binding(
                    get: { self.pendingSelectedTemplates },
                    set: { self.pendingSelectedTemplates = $0 }
                )
            )
        )
    }
    
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    // MARK: - Widget Sync
    func startWidgetSyncTimer() {
        if widgetSyncTimer != nil {
            print("⏱️ WorkoutTrackerPresenter.startWidgetSyncTimer() skipped; timer already running")
            return
        }
        print("⏱️ WorkoutTrackerPresenter.startWidgetSyncTimer() creating timer")
        widgetSyncTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.syncPendingSetCompletionFromWidget()
                self?.syncPendingWorkoutCompletionFromWidget()
            }
        }
    }
    
    func stopWidgetSyncTimer() {
        guard widgetSyncTimer != nil else {
            print("⏱️ stopWidgetSyncTimer() skipped; no timer running")
            return
        }
        print("⏱️ WorkoutTrackerPresenter.stopWidgetSyncTimer() invalidating timer")
        widgetSyncTimer?.invalidate()
        widgetSyncTimer = nil
    }
    
    func syncPendingSetCompletionFromWidget() {
        guard let pending = SharedWorkoutStorage.pendingSetCompletion else { return }
        print("🔍 Widget Completion: Found pending for set '\(pending.setId)'")
        print("   Values: weight=\(pending.weightKg ?? 0)kg, reps=\(pending.reps ?? 0)")
        
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { exercise in
            exercise.sets.contains { $0.id == pending.setId }
        }) else {
            print("❌ Widget Completion: Set not found in current workout")
            print("   Available set IDs: \(workoutSession.exercises.flatMap { $0.sets.map { $0.id } })")
            SharedWorkoutStorage.clearPendingSetCompletion()
            return
        }
        
        guard let setIndex = workoutSession.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == pending.setId }) else {
            print("❌ Set ID matched but not found in sets array")
            SharedWorkoutStorage.clearPendingSetCompletion()
            return
        }
        
        let exercise = workoutSession.exercises[exerciseIndex]
        print("✓ Found in exercise \(exerciseIndex): '\(exercise.name)' at set index \(setIndex)")
        
        var updatedSet = exercise.sets[setIndex]
        
        let beforeComplete = updatedSet.completedAt
        print("   Before: completedAt=\(beforeComplete?.description ?? "nil")")
        
        if let weight = pending.weightKg { updatedSet.weightKg = weight }
        if let reps = pending.reps { updatedSet.reps = reps }
        if let distance = pending.distanceMeters { updatedSet.distanceMeters = distance }
        if let duration = pending.durationSec { updatedSet.durationSec = duration }
        updatedSet.completedAt = pending.completedAt
        
        print("   After: completedAt=\(updatedSet.completedAt?.description ?? "nil")")
        
        SharedWorkoutStorage.clearPendingSetCompletion()
        
        print("✅ Widget Completion: Routing through updateSet() to trigger all mechanics")
        
        updateSet(updatedSet, in: exercise.id)
    }
    
    func updateSet(_ updatedSet: WorkoutSetModel, in exerciseId: String) {
        print("✏️ WorkoutTrackerPresenter.updateSet() exerciseId=\(exerciseId) setId=\(updatedSet.id)")
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
        try? interactor.setActiveLocalWorkoutSession(workoutSession)
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
    
    func addSet(exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }),
              let userId = interactor.currentUser?.userId else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        let existingSets = updatedExercises[exerciseIndex].sets
        let newIndex = existingSets.count + 1
        let lastSet = existingSets.last
        
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
        workoutSession.updateExercises(updatedExercises)
        self.workoutSession = workoutSession
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
    
    func deleteSet(setId: String, exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].sets.removeAll { $0.id == setId }
        
        for index in updatedExercises[exerciseIndex].sets.indices {
            updatedExercises[exerciseIndex].sets[index].index = index + 1
        }
        
        workoutSession.updateExercises(updatedExercises)
        self.workoutSession = workoutSession
        restBeforeSetIdToSec.removeValue(forKey: setId)
        syncCurrentExerciseIndexToFirstIncomplete(in: updatedExercises)
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
    
    func updateExerciseNotes(_ notes: String, exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].notes = notes.isEmpty ? nil : notes
        workoutSession.updateExercises(updatedExercises)
        self.workoutSession = workoutSession
        saveWorkoutProgress()
    }
    
    func updateRestBefore(setId: String, seconds: Int?) {
        if let seconds {
            restBeforeSetIdToSec[setId] = seconds
        } else {
            restBeforeSetIdToSec.removeValue(forKey: setId)
        }
        saveWorkoutProgress()
    }

    func onRestPickerRequested(setId: String) {
        restPickerTargetSetId = setId
        let existing = restBeforeSetIdToSec[setId] ?? restDurationSeconds
        restPickerMinutesSelection = existing / 60
        restPickerSecondsSelection = existing % 60

        router.showRestModal(
            primaryButtonAction: { [weak self] in
                guard let self else { return }
                let totalSeconds = (self.restPickerMinutesSelection * 60) + self.restPickerSecondsSelection
                self.updateRestBefore(setId: setId, seconds: totalSeconds > 0 ? totalSeconds : nil)
                self.router.dismissModal()
            },
            secondaryButtonAction: { [weak self] in
                self?.router.dismissModal()
            },
            minutesSelection: Binding(
                get: { self.restPickerMinutesSelection },
                set: { self.restPickerMinutesSelection = $0 }
            ),
            secondsSelection: Binding(
                get: { self.restPickerSecondsSelection },
                set: { self.restPickerSecondsSelection = $0 }
            )
        )
    }

    func startRestTimer(durationSeconds: Int = 0) {
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

    func syncPendingWorkoutCompletionFromWidget() {
        guard let pending = SharedWorkoutStorage.pendingWorkoutCompletion else { return }

        print("🔍 Widget Workout Completion: Found pending for session '\(pending.sessionId)'")
        
        guard pending.sessionId == workoutSession.id else {
            print("❌ Widget Workout Completion: Session ID mismatch")
            SharedWorkoutStorage.clearPendingWorkoutCompletion()
            return
        }
        
        print("✅ Widget Workout Completion: Triggering finishWorkout()")
        
        SharedWorkoutStorage.clearPendingWorkoutCompletion()
    }
    
    func onGymProfilePressed() {
        guard let gymProfile = favouriteGymProfile else { return }
        router.showGymProfileView(gymProfile: gymProfile)
    }

    // MARK: - Exercise Management
    func addSelectedExercises() {
        let templates = self.pendingSelectedTemplates
        guard !templates.isEmpty, let userId = interactor.currentUser?.userId else { return }
        var updated = workoutSession.exercises
        let startIndex = updated.count
        for (offset, template) in templates.enumerated() {
            let index = startIndex + offset + 1
            let mode = WorkoutSessionModel.trackingMode(for: template)
            let defaultSets = WorkoutSessionModel.defaultSets(trackingMode: mode, authorId: userId)
            let imageName = Constants.exerciseImageName(for: template.name)
            let newExercise = WorkoutExerciseModel(
                id: UUID().uuidString,
                authorId: userId,
                templateId: template.id,
                name: template.name,
                trackingMode: mode,
                index: index,
                notes: nil,
                imageName: imageName,
                sets: defaultSets
            )
            updated.append(newExercise)
        }
        workoutSession.updateExercises(updated)
        self.workoutSession = workoutSession
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)
        if currentExerciseIndex < updated.count {
            expandedExerciseIds.removeAll()
            expandedExerciseIds.insert(updated[currentExerciseIndex].id)
        }
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
        
        self.pendingSelectedTemplates = []
    }
    
    func deleteExercise(_ exerciseId: String) {
        var updated = workoutSession.exercises
        guard let idx = updated.firstIndex(where: { $0.id == exerciseId }) else { return }
        updated.remove(at: idx)
        for index in updated.indices { updated[index].index = index + 1 }
        workoutSession.updateExercises(updated)
        self.workoutSession = workoutSession
        expandedExerciseIds.remove(exerciseId)
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)
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
    
    func onWorkoutSettingsPressed() {
        router.showWorkoutSettingsView(delegate: WorkoutSettingsDelegate())
    }
    
    func moveExercises(from source: IndexSet, to destination: Int) {
        var updated = workoutSession.exercises
        updated.move(fromOffsets: source, toOffset: destination)
        applyReorderedExercises(updated, movedFrom: source.first, movedTo: destination)

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

    func reorderExercises(from sourceIndex: Int, to targetIndex: Int) {
        guard sourceIndex != targetIndex else { return }
        var updated = workoutSession.exercises
        let element = updated.remove(at: sourceIndex)
        updated.insert(element, at: targetIndex)
        applyReorderedExercises(updated, movedFrom: sourceIndex, movedTo: targetIndex)
    }
    
    func buttonColor(set: WorkoutSetModel, canComplete: Bool) -> Color {
        if set.completedAt != nil {
            return .green
        } else if canComplete {
            return .secondary
        } else {
            return .red.opacity(0.6)
        }
    }
    
    func canComplete(trackingMode: TrackingMode, set: WorkoutSetModel) -> Bool {
        switch trackingMode {
        case .weightReps:
            let hasValidWeight = set.weightKg == nil || set.weightKg! >= 0
            let hasValidReps = set.reps != nil && set.reps! > 0
            return hasValidWeight && hasValidReps
            
        case .repsOnly:
            return set.reps != nil && set.reps! > 0
            
        case .timeOnly:
            return set.durationSec != nil && set.durationSec! > 0
            
        case .distanceTime:
            let hasValidDistance = set.distanceMeters != nil && set.distanceMeters! > 0
            let hasValidTime = set.durationSec != nil && set.durationSec! > 0
            return hasValidDistance && hasValidTime
        }
    }
        
    func validateSetData(trackingMode: TrackingMode, set: WorkoutSetModel) -> Bool {
        switch trackingMode {
        case .weightReps:
            return validateWeightReps(set: set)
        case .repsOnly:
            return validateRepsOnly(set: set)
        case .timeOnly:
            return validateTimeOnly(set: set)
        case .distanceTime:
            return validateDistanceTime(set: set)
        }
    }
    
    func validateWeightReps(set: WorkoutSetModel) -> Bool {
        // Weight must be non-negative (including 0 for bodyweight exercises)
        if let weight = set.weightKg, weight < 0 {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Weight must be a non-negative number")
            return false
        }
        
        // Reps must be positive
        guard let reps = set.reps, reps > 0 else {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
            return false
        }
        
        return true
    }
    
    func validateRepsOnly(set: WorkoutSetModel) -> Bool {
        // Reps must be positive
        guard let reps = set.reps, reps > 0 else {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Reps must be a positive number")
            return false
        }
        
        return true
    }
    
    func validateTimeOnly(set: WorkoutSetModel) -> Bool {
        // Time must be positive
        guard let duration = set.durationSec, duration > 0 else {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
            return false
        }
        
        return true
    }
    
    func validateDistanceTime(set: WorkoutSetModel) -> Bool {
        // Distance must be positive
        guard let distance = set.distanceMeters, distance > 0 else {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Distance must be a positive number")
            return false
        }
        
        // Time must be positive
        guard let duration = set.durationSec, duration > 0 else {
            router.showSimpleAlert(title: "Invalid Set Data", subtitle: "Duration must be a positive time")
            return false
        }
        
        return true
    }

    func onWarmupSetHelpPressed() {
        router.showWarmupSetInfoModal {
            self.router.dismissModal()
        }
    }

}
