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
class WorkoutTrackerPresenter {

    let interactor: WorkoutTrackerInteractor
    let router: WorkoutTrackerRouter

    // MARK: - State Properties
    var workoutSession: WorkoutSessionModel {
        didSet {
            saveWorkoutProgress()
            handleWorkoutSessionChange(from: oldValue)
        }
    }
    
    var restDurationSeconds: Int {
        interactor.workoutSettings.defaultRestDurationSeconds
    }
    var restBeforeSetIdToSec: [String: Int] = [:]
    var restPickerTargetSetId: String?
    var restPickerMinutesSelection: Int = 0
    var restPickerSecondsSelection: Int = 0

    var pendingSelectedTemplates: [WorkoutTemplateExercise] = []

    var editMode: EditMode = .inactive
    
    var startTime: Date {
        self.workoutSession.dateCreated
    }
    
    var elapsedTime: TimeInterval = 0
    var isActive = true
    
    var expandedExerciseIds: Set<String> = []
    var workoutNotes = ""
    var currentExerciseIndex = 0
    
    var previousWorkoutSession: WorkoutSessionModel?
    var exerciseUnitPreferences: [String: (weightUnit: ExerciseWeightUnit, distanceUnit: ExerciseDistanceUnit)] = [:]

    // Internal timers
    var widgetSyncTimer: Timer?

    // Prevents handleWorkoutSessionChange from double-processing when updateSet() is the caller
    private var isProcessingUpdateSet = false
    
    // Notification identifier for rest timer
    let restTimerNotificationId = "workout-rest-timer"
    
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
    ) throws {
        self.interactor = interactor
        self.router = router
        
        guard let session = interactor.activeSession else {
            throw WorkoutTrackerError.noActiveWorkout
        }
        
        self.workoutSession = session
        loadUnitPreferences()
        
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Ensure an existing Live Activity is reused, otherwise start one
        self.interactor.ensureLiveActivity(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil
        )
        #endif
        
        applyWarmupSetting()
        
        syncCurrentExerciseIndexToFirstIncomplete(in: workoutSession.exercises)

        // Expand first incomplete exercise by default (fallback to first if all complete)
        if let idx = firstIncompleteExerciseIndex(in: workoutSession.exercises) {
            expandedExerciseIds.insert(workoutSession.exercises[idx].id)
        } else if let firstExercise = workoutSession.exercises.first {
            expandedExerciseIds.insert(firstExercise.id)
        }
        
        // Check for pending widget completions that happened while backgrounded
        syncPendingSetCompletionFromWidget()

    }
    
    func loadUnitPreferences() {
        exerciseUnitPreferences.removeAll(keepingCapacity: true)
        for exercise in workoutSession.exercises {
            let preference = interactor.getPreference(templateId: exercise.templateId)
            exerciseUnitPreferences[exercise.templateId] = (
                weightUnit: preference.weightUnit,
                distanceUnit: preference.distanceUnit
            )
        }
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

    // MARK: - Display Settings

    var showWorkoutTimer: Bool {
        interactor.workoutSettings.showWorkoutTimer
    }
    
    var showBodyweightContribution: Bool {
        interactor.workoutSettings.showBodyweightContribution
    }
    var showRIRTracking: Bool { interactor.workoutSettings.rirTracking }

    // MARK: - Lifecycle
    @MainActor
    deinit {
        stopWidgetSyncTimer()
    }
    
    func onAppear() async {
        startWidgetSyncTimer()
        
        // Ensure HealthKit authorization before starting HK session
        let healthKitManager = HealthKitManager()
        if healthKitManager.canRequestAuthorisation() && healthKitManager.needsAuthorisationForRequiredTypes() {
            do {
                try await healthKitManager.requestAuthorisation()
            } catch { }
        }
        
        // Apply keep-alive setting
        UIApplication.shared.isIdleTimerDisabled = interactor.workoutSettings.keepAlive

        // Verify workout write permission before starting
        guard !HealthKitService().needsAuthorisationForRequiredTypes() else { return }

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        // Avoid starting the same HK workout session multiple times for this workout.
        if SharedWorkoutStorage.hkStartedSessionId == workoutSession.id { return }
        interactor.setWorkoutConfiguration(activityType: .traditionalStrengthTraining, location: .indoor)
        interactor.startWorkout(workout: workoutSession)
        SharedWorkoutStorage.hkStartedSessionId = workoutSession.id
        #endif
    }
    
    func onScenePhaseChange(oldPhase: ScenePhase, newPhase: ScenePhase) {
        if newPhase == .active && oldPhase == .background {
            syncPendingSetCompletionFromWidget()
        }
    }

    private func applyWarmupSetting() {
        guard !interactor.workoutSettings.addSmartWarmUps else { return }
        var updated = workoutSession.exercises
        var changed = false
        for index in updated.indices {
            let before = updated[index].sets.count
            updated[index].sets.removeAll { $0.isWarmup && $0.completedAt == nil }
            if updated[index].sets.count != before {
                for jindex in updated[index].sets.indices { updated[index].sets[jindex].index = jindex + 1 }
                changed = true
            }
        }
        guard changed else { return }
        workoutSession.updateExercises(updated)
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
                previousWorkoutSession = nil
            }
        }
    }
    
    // MARK: - Workout Actions
    
    private func discardWorkout() {
        stopWidgetSyncTimer()
        try? interactor.deleteActiveSession()
        UIApplication.shared.isIdleTimerDisabled = false
        SharedWorkoutStorage.clearHKStartedSessionId()
        router.dismissScreen()

        let sessionSnapshot = workoutSession
        Task {
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            interactor.discardWorkout()
            await interactor.discardLiveActivity()
            interactor.endLiveActivity(session: sessionSnapshot, isCompleted: false, statusMessage: "Workout Discarded")
            #endif
        }
    }

    func onDiscardWorkoutPressed() {
        router.showAlert(
            title: "End Workout?",
            subtitle: "Are you sure you want to discard this workout?"
        ) {
            AnyView(
                VStack {
                    Button("Cancel", role: .cancel) { }
                    Button("Discard", role: .destructive) {
                        self.discardWorkout()
                    }
                }
            )
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
        
    }

    // MARK: - Persistence
    
    func saveWorkoutProgress() {
        do {
            try interactor.updateActiveSession(workoutSession)
        } catch {
            router.showSimpleAlert(title: "Unable to Save Progress", subtitle: "We were unable to save your workout. Please try again.")
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
        if let idx = firstIncompleteExerciseIndex(in: exercises) {
            currentExerciseIndex = idx
        } else {
            currentExerciseIndex = max(0, exercises.isEmpty ? 0 : exercises.count - 1)
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
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)
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
    }
    
    func presentAddExercise() {
        router.showExercisesPickerView(
            delegate: ExercisesPickerDelegate(
                addedExercises: Binding(
                    get: { self.pendingSelectedTemplates },
                    set: { self.pendingSelectedTemplates = $0 }
                )
            )
        )
    }
    
    #if DEV || MOCK
    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    #endif

    enum WorkoutTrackerError: LocalizedError {
        case noLocalActiveWorkout
        case noActiveWorkout

        var errorDescription: String? {
            switch self {
            case .noLocalActiveWorkout:
                return "No local active workout available"
            case .noActiveWorkout:
                return "No active workout available"
            }
        }
    }

    // MARK: - Widget Sync
    func startWidgetSyncTimer() {
        if widgetSyncTimer != nil { return }
        widgetSyncTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.syncPendingSetCompletionFromWidget()
                self?.syncPendingWorkoutCompletionFromWidget()
            }
        }
    }

    func stopWidgetSyncTimer() {
        guard widgetSyncTimer != nil else {
            return
        }
        widgetSyncTimer?.invalidate()
        widgetSyncTimer = nil
    }

    func syncPendingSetCompletionFromWidget() {
        guard let pending = SharedWorkoutStorage.pendingSetCompletion else { return }

        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { exercise in
            exercise.sets.contains { $0.id == pending.setId }
        }) else {
            SharedWorkoutStorage.clearPendingSetCompletion()
            return
        }

        guard let setIndex = workoutSession.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == pending.setId }) else {
            SharedWorkoutStorage.clearPendingSetCompletion()
            return
        }

        let exercise = workoutSession.exercises[exerciseIndex]
        var updatedSet = exercise.sets[setIndex]

        if let weight = pending.weightKg { updatedSet.weightKg = weight }
        if let reps = pending.reps { updatedSet.reps = reps }
        if let distance = pending.distanceMeters { updatedSet.distanceMeters = distance }
        if let duration = pending.durationSec { updatedSet.durationSec = duration }
        updatedSet.completedAt = pending.completedAt

        SharedWorkoutStorage.clearPendingSetCompletion()
        updateSet(updatedSet, in: exercise.id)
    }

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

        // Propagate weight/reps changes to uncompleted sibling sets with matching values
        if interactor.workoutSettings.propagateChanges {
            let original = exerciseBefore.sets[setIndex]
            let weightChanged = original.weightKg != updatedSet.weightKg
            let repsChanged = original.reps != updatedSet.reps
            if (weightChanged || repsChanged) && updatedSet.completedAt == nil {
                for index in updatedExercises[exerciseIndex].sets.indices where index != setIndex {
                    var sibling = updatedExercises[exerciseIndex].sets[index]
                    guard sibling.completedAt == nil,
                          sibling.weightKg == original.weightKg,
                          sibling.reps == original.reps else { continue }
                    if weightChanged { sibling.weightKg = updatedSet.weightKg }
                    if repsChanged { sibling.reps = updatedSet.reps }
                    updatedExercises[exerciseIndex].sets[index] = sibling
                }
            }
        }

        let isExerciseCompleteNow = !updatedExercises[exerciseIndex].sets.isEmpty && updatedExercises[exerciseIndex].sets.allSatisfy { $0.completedAt != nil }
        isProcessingUpdateSet = true
        workoutSession.updateExercises(updatedExercises)
        isProcessingUpdateSet = false

        let allSets = updatedExercises.flatMap { $0.sets }
        let isAllSetsComplete = !allSets.isEmpty && allSets.allSatisfy { $0.completedAt != nil }

        if previousCompletedAt == nil, updatedSet.completedAt != nil, !isAllSetsComplete,
           interactor.workoutSettings.useRestTimers {
            let exercise = workoutSession.exercises[exerciseIndex]
            startRestTimer(durationSeconds: restDuration(for: exercise, customSetId: updatedSet.id))
        }

        if !wasExerciseCompleteBefore && isExerciseCompleteNow {
            let nextIndex = exerciseIndex + 1
            if nextIndex < updatedExercises.count && interactor.workoutSettings.exerciseAutoNext {
                expandedExerciseIds.removeAll()
                expandedExerciseIds.insert(updatedExercises[nextIndex].id)
                currentExerciseIndex = nextIndex
            } else if nextIndex >= updatedExercises.count {
                expandedExerciseIds.remove(updatedExercises[exerciseIndex].id)
            }
        }

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(params: LiveActivityUpdateParams(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        ))
        #endif
    }

    func updateExerciseNotes(_ notes: String, exerciseId: String) {
        guard let exerciseIndex = workoutSession.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }

        var updatedExercises = workoutSession.exercises
        updatedExercises[exerciseIndex].notes = notes.isEmpty ? nil : notes
        workoutSession.updateExercises(updatedExercises)
    }

    func updateRestBefore(setId: String, seconds: Int?) {
        if let seconds {
            restBeforeSetIdToSec[setId] = seconds
        } else {
            restBeforeSetIdToSec.removeValue(forKey: setId)
        }
    }

    private func restDuration(for exercise: WorkoutExerciseModel, customSetId: String? = nil) -> Int {
        // 1. Per-set custom override (set via swipe action in SetTrackerView)
        if let setId = customSetId, let custom = restBeforeSetIdToSec[setId] {
            return custom
        }
        // 2. Per-exercise-type setting from user preferences
        let settings = interactor.workoutSettings
        if let exerciseType = interactor.allExercises.first(where: { $0.id == exercise.templateId })?.type {
            if let duration = settings.restDurationsByExerciseType[exerciseType.rawValue] {
                return duration
            }
            // 3. Built-in defaults per type (matches TimerDurationPresenter.defaultDurations)
            if let defaultDuration = TimerDurationPresenter.defaultDurations[exerciseType] {
                return defaultDuration
            }
        }
        // 4. Global default
        return settings.defaultRestDurationSeconds
    }

    func startRestTimer(durationSeconds: Int = 0) {
        let duration = durationSeconds > 0 ? durationSeconds : restDurationSeconds
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.startRest(durationSeconds: duration, session: workoutSession, currentExerciseIndex: currentExerciseIndex)

        // Schedule local notification for when rest is complete
        if let endTime = interactor.restEndTime {
            Task {
                do {
                    let delegate = PushNotificationDelegate(
                        identifier: restTimerNotificationId,
                        title: "Rest Complete",
                        subtitle: "Time to get back to your workout!",
                        triggerDate: endTime,
                        sound: true,
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

    private func handleWorkoutSessionChange(from oldSession: WorkoutSessionModel) {
        guard !isProcessingUpdateSet else { return }

        // Build a flat lookup of old sets by id
        var oldSets: [String: WorkoutSetModel] = [:]
        for exercise in oldSession.exercises {
            for set in exercise.sets {
                oldSets[set.id] = set
            }
        }

        // Find the first set that transitioned from incomplete → complete
        var foundSetId: String?
        var foundExerciseIndex: Int?
        outer: for (exerciseIndex, exercise) in workoutSession.exercises.enumerated() {
            for set in exercise.sets {
                let wasCompleted = oldSets[set.id]?.completedAt != nil
                let isCompleted = set.completedAt != nil
                if !wasCompleted && isCompleted {
                    foundSetId = set.id
                    foundExerciseIndex = exerciseIndex
                    break outer
                }
            }
        }

        guard let setId = foundSetId, let exerciseIndex = foundExerciseIndex else { return }

        let exercise = workoutSession.exercises[exerciseIndex]

        // Start rest timer (skip if every set in the workout is now complete)
        let allSets = workoutSession.exercises.flatMap { $0.sets }
        let isAllSetsComplete = !allSets.isEmpty && allSets.allSatisfy { $0.completedAt != nil }
        if !isAllSetsComplete && interactor.workoutSettings.useRestTimers {
            startRestTimer(durationSeconds: restDuration(for: exercise, customSetId: setId))
        }

        // Auto-next exercise
        let oldExercise = oldSession.exercises.first(where: { $0.id == exercise.id })
        let wasExerciseCompleteBefore = oldExercise.map { exercise in
            !exercise.sets.isEmpty && exercise.sets.allSatisfy { $0.completedAt != nil }
        } ?? false
        let isExerciseCompleteNow = !exercise.sets.isEmpty && exercise.sets.allSatisfy { $0.completedAt != nil }

        if !wasExerciseCompleteBefore && isExerciseCompleteNow {
            let nextIndex = exerciseIndex + 1
            let exercises = workoutSession.exercises
            if nextIndex < exercises.count && interactor.workoutSettings.exerciseAutoNext {
                expandedExerciseIds.removeAll()
                expandedExerciseIds.insert(exercises[nextIndex].id)
                currentExerciseIndex = nextIndex
            } else if nextIndex >= exercises.count {
                expandedExerciseIds.remove(exercises[exerciseIndex].id)
            }
        }

        // Update Live Activity
        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(params: LiveActivityUpdateParams(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        ))
        #endif
    }

    func syncPendingWorkoutCompletionFromWidget() {
        guard let pending = SharedWorkoutStorage.pendingWorkoutCompletion else { return }

        guard pending.sessionId == workoutSession.id else {
            SharedWorkoutStorage.clearPendingWorkoutCompletion()
            return
        }

        SharedWorkoutStorage.clearPendingWorkoutCompletion()
    }

    func onGymProfilePressed() {
        guard let gymProfile = favouriteGymProfile else { return }
        let delegate = GymProfileDelegate(gymProfile: gymProfile)
        router.showGymProfileView(delegate: delegate)
    }

    // MARK: - Exercise Management
    func addSelectedExercises() {
        let templates = self.pendingSelectedTemplates
        guard !templates.isEmpty, let userId = interactor.currentUser?.userId else { return }
        var updated = workoutSession.exercises
        let startIndex = updated.count
        for (offset, template) in templates.enumerated() {
            let index = startIndex + offset + 1
            let exercise = template.exercise
            let mode = WorkoutSessionModel.trackingMode(for: exercise)
            let targetCount = max(template.setTargets.count, 1)
            let defaultSets = WorkoutSessionModel.defaultSets(
                trackingMode: mode,
                authorId: userId,
                targetCount: targetCount
            )
            let imageName = Constants.exerciseImageName(for: exercise.name)
            let newExercise = WorkoutExerciseModel(
                id: UUID().uuidString,
                authorId: userId,
                templateId: exercise.id,
                name: exercise.name,
                trackingMode: mode,
                index: index,
                notes: nil,
                imageName: imageName,
                sets: defaultSets,
                setTargets: template.setTargets,
                chosenResistanceEquipment: exercise.resistanceEquipment,
                chosenSupportEquipment: exercise.supportEquipment
            )
            updated.append(newExercise)
        }
        workoutSession.updateExercises(updated)
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)
        if currentExerciseIndex < updated.count {
            expandedExerciseIds.removeAll()
            expandedExerciseIds.insert(updated[currentExerciseIndex].id)
        }

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(params: LiveActivityUpdateParams(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        ))
        #endif

        self.pendingSelectedTemplates = []
    }

    func deleteExercise(_ exerciseId: String) {
        var updated = workoutSession.exercises
        guard let idx = updated.firstIndex(where: { $0.id == exerciseId }) else { return }
        updated.remove(at: idx)
        for index in updated.indices { updated[index].index = index + 1 }
        workoutSession.updateExercises(updated)
        expandedExerciseIds.remove(exerciseId)
        syncCurrentExerciseIndexToFirstIncomplete(in: updated)

        #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
        interactor.updateLiveActivity(params: LiveActivityUpdateParams(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        ))
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
        interactor.updateLiveActivity(params: LiveActivityUpdateParams(
            session: workoutSession,
            isActive: isActive,
            currentExerciseIndex: currentExerciseIndex,
            restEndsAt: interactor.restEndTime,
            statusMessage: isRestActive ? "Resting" : nil,
            totalVolumeKg: computeTotalVolumeKg(),
            elapsedTime: elapsedTime
        ))
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

    func finishWorkout() {
        stopWidgetSyncTimer()
        workoutSession.endSession(at: Date())
        UIApplication.shared.isIdleTimerDisabled = false
        SharedWorkoutStorage.clearHKStartedSessionId()
        router.dismissScreen()

        let sessionSnapshot = workoutSession
        Task {
            interactor.trackEvent(
                eventName: "finish_workout_debug",
                parameters: [
                    "session_id": sessionSnapshot.id,
                    "template_id": sessionSnapshot.workoutTemplateId ?? "nil",
                    "plan_id": sessionSnapshot.trainingProgramId ?? "nil"
                ],
                type: .info
            )
            #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
            interactor.endWorkout()
            #endif
            do {
                try await interactor.endWorkoutSession(sessionSnapshot)
                try await interactor.addWorkoutStreakEvent()
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
                interactor.endLiveActivity(session: sessionSnapshot, isCompleted: true, statusMessage: "Workout ended & saved.")
                #endif
            } catch {
                interactor.trackEvent(eventName: "finish_workout_save_error", parameters: ["error": error.localizedDescription], type: .severe)
            }
        }
    }
}
