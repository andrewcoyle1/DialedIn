//
//  DevSettingsPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftfulUtilities

@Observable
@MainActor
class DevSettingsPresenter {

    private let interactor: DevSettingsInteractor
    private let router: DevSettingsRouter
    
    private(set) var isReseeding = false
    private(set) var reseedingMessage = ""
    private(set) var fetchedSession: WorkoutSessionModel?
    private(set) var isFetchingSession = false
    private(set) var fetchError: String?

    var testSessionId = ""
    
    var isInNotificationsABTest: Bool = false
    var paywallTest: PaywallTestOption = .default

    init(
        interactor: DevSettingsInteractor,
        router: DevSettingsRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func authParams() -> [(key: String, value: Any)] {
        interactor.auth?.eventParameters.asAlphabeticalArray ?? []
    }
    
    func userParams() -> [(key: String, value: Any)] {
        interactor.currentUser?.eventParameters.asAlphabeticalArray ?? []
    }
    
    func loadABTests() {
        isInNotificationsABTest = interactor.activeTests.notificationsTest
        paywallTest = interactor.activeTests.paywallTest
    }

    func handleNotificationTestChange(oldValue: Bool, newValue: Bool) {
        updateTest(property: &isInNotificationsABTest, newValue: newValue, savedValue: interactor.activeTests.notificationsTest) { tests in
            tests.update(notificationsTest: newValue)
        }
    }
    
    func handlePaywallOptionChange(oldValue: PaywallTestOption, newValue: PaywallTestOption) {
        updateTest(
            property: &paywallTest,
            newValue: newValue,
            savedValue: interactor.activeTests.paywallTest,
            updateAction: { tests in
                tests.update(paywallTest: newValue)
            }
        )
    }

    private func updateTest<Value: Equatable>(
        property: inout Value,
        newValue: Value,
        savedValue: Value,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var tests = interactor.activeTests
                updateAction(&tests)
                try interactor.override(updatedTests: tests)
            } catch {
                property = savedValue
                router.showAlert(error: error)
            }
        }
    }
    
    func deviceParams() -> [(key: String, value: Any)] {
        SwiftfulUtilities.Utilities.eventParameters.asAlphabeticalArray
    }
    
    func getLocalExercises() -> [ExerciseTemplateModel] {
        (try? interactor.getAllLocalExerciseTemplates()) ?? []
    }
    
    func getLocalWorkoutTemplates() -> [WorkoutTemplateModel] {
        (try? interactor.getAllLocalWorkoutTemplates()) ?? []
    }
    
    func getLocalTrainingPlan() -> TrainingPlan? {
        interactor.currentTrainingPlan
    }
    
    func getCurrentTrainingPlanWeek() -> TrainingWeek? {
        interactor.getCurrentWeek()
    }
    
    func getTodaysWorkouts() -> [ScheduledWorkout] {
        interactor.getTodaysWorkouts()
    }
    
    func getActiveSession() -> WorkoutSessionModel? {
        interactor.activeSession
    }
    
    func getActiveLocalWorkoutSession() -> WorkoutSessionModel? {
        try? interactor.getActiveLocalWorkoutSession()
    }
    
    func getRecentWorkoutSessions() -> [WorkoutSessionModel] {
        (try? interactor.getAllLocalWorkoutSessions()) ?? []
    }
        
    func resetExerciseSeeding() async {
        isReseeding = true
        reseedingMessage = "Resetting exercises..."
        
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltExercises")
        UserDefaults.standard.removeObject(forKey: "prebuiltExercisesSeedingVersion")
        
        reseedingMessage = "Complete! Restart app to reseed."
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    func resetWorkoutSeeding() async {
        isReseeding = true
        reseedingMessage = "Resetting workouts..."
        
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltWorkouts")
        UserDefaults.standard.removeObject(forKey: "prebuiltWorkoutsSeedingVersion")
        
        reseedingMessage = "Complete! Restart app to reseed."
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    func resetAllSeeding() async {
        isReseeding = true
        reseedingMessage = "Resetting all seeding..."
        
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltExercises")
        UserDefaults.standard.removeObject(forKey: "prebuiltExercisesSeedingVersion")
        UserDefaults.standard.removeObject(forKey: "hasSeededPrebuiltWorkouts")
        UserDefaults.standard.removeObject(forKey: "prebuiltWorkoutsSeedingVersion")
        
        reseedingMessage = "Complete! Restart app to reseed."
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    func resetTodaysWorkouts() async {
        isReseeding = true
        reseedingMessage = "Resetting today's workouts..."
        
        guard var plan = interactor.currentTrainingPlan else {
            reseedingMessage = "No active plan"
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isReseeding = false
            reseedingMessage = ""
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find and reset today's workouts
        for (weekIndex, week) in plan.weeks.enumerated() {
            for (workoutIndex, workout) in week.scheduledWorkouts.enumerated() {
                if let scheduledDate = workout.scheduledDate,
                   calendar.isDate(scheduledDate, inSameDayAs: today) {
                    // Reset to incomplete
                    let resetWorkout = ScheduledWorkout(
                        id: workout.id,
                        workoutTemplateId: workout.workoutTemplateId,
                        dayOfWeek: workout.dayOfWeek,
                        scheduledDate: workout.scheduledDate,
                        completedSessionId: nil,
                        isCompleted: false,
                        notes: workout.notes
                    )
                    plan.weeks[weekIndex].scheduledWorkouts[workoutIndex] = resetWorkout
                }
            }
        }
        
        // Save updated plan
        try? await interactor.updatePlan(plan)
        
        reseedingMessage = "Reset complete!"
        
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        isReseeding = false
        reseedingMessage = ""
    }
    
    func fetchSessionFromFirebase() async {
        isFetchingSession = true
        fetchError = nil
        fetchedSession = nil
        
        do {
            let session = try await interactor.getWorkoutSession(id: testSessionId)
            await MainActor.run {
                fetchedSession = session
                isFetchingSession = false
            }
        } catch {
            await MainActor.run {
                fetchError = error.localizedDescription
                isFetchingSession = false
            }
        }
    }
    
    func onForceFreshAnonUser() {
        defer {
            router.dismissScreen()
            Task {
                try? await Task.sleep(for: .seconds(1))
                interactor.updateAppState(showTabBarView: false)
            }
        }
        interactor.trackEvent(event: Event.forceSignOutStart)
        Task {
            do {
                try await interactor.signOut()
                interactor.trackEvent(event: Event.forceSignOutSuccess)

            } catch {
                interactor.trackEvent(event: Event.forceSignOutFail(error: error))
                router.showAlert(error: error)
            }
        }
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }

    enum Event: LoggableEvent {
        case forceSignOutStart
        case forceSignOutSuccess
        case forceSignOutFail(error: Error)

        var eventName: String {
            switch self {
            case .forceSignOutStart:            return "DevSettingsView_ForceSignOut_Start"
            case .forceSignOutSuccess:          return "DevSettingsView_ForceSignOut_Success"
            case .forceSignOutFail:             return "DevSettingsView_ForceSignOut_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .forceSignOutFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .forceSignOutFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
