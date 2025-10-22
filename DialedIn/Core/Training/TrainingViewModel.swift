//
//  TrainingViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class TrainingViewModel {
    
    private let authManager: AuthManager
    private let exerciseTemplateManager: ExerciseTemplateManager
    private let exerciseUnitPreferenceManager: ExerciseUnitPreferenceManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let workoutSessionManager: WorkoutSessionManager
    private let trainingPlanManager: TrainingPlanManager
    private let logManager: LogManager
    
    private(set) var searchExerciseTask: Task<Void, Never>?
    private(set) var searchWorkoutTask: Task<Void, Never>?
    private(set) var isLoading: Bool = false
    private(set) var searchText: String = ""
    var presentationMode: TrainingPresentationMode = .program
    var showNotificationsView: Bool = false
    var showAlert: AnyAppAlert?
    var isShowingInspector: Bool = false
    var selectedExerciseTemplate: ExerciseTemplateModel?
    var selectedWorkoutTemplate: WorkoutTemplateModel?
    var workoutToStart: WorkoutTemplateModel?
    var scheduledWorkoutToStart: ScheduledWorkout?
    var showCreateExercise: Bool = false
    var showCreateWorkout: Bool = false
    var programActiveSheet: ActiveSheet?
    var selectedHistorySession: WorkoutSessionModel?
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    init(
        container: DependencyContainer
    ) {
        self.authManager = container.resolve(AuthManager.self)!
        self.exerciseTemplateManager = container.resolve(ExerciseTemplateManager.self)!
        self.exerciseUnitPreferenceManager = container.resolve(ExerciseUnitPreferenceManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    func onNotificationsPressed() {
        showNotificationsView = true
    }
    
    var currentMenuIcon: String {
        switch presentationMode {
        case .program:
            return "calendar.circle.fill"
        case .workouts:
            return "dumbbell.fill"
        case .exercises:
            return "list.bullet.rectangle.portrait.fill"
        case .history:
            return "clock.fill"
        }
    }
    
    var navigationSubtitle: String {
        if presentationMode == .program, let plan = trainingPlanManager.currentTrainingPlan {
            let todaysWorkouts = trainingPlanManager.getTodaysWorkouts()
            if !todaysWorkouts.isEmpty {
                let completedCount = todaysWorkouts.filter { $0.isCompleted }.count
                if completedCount == todaysWorkouts.count {
                    return "\(plan.name) • Today's workout complete ✓"
                } else {
                    return "\(plan.name) • Workout scheduled for today"
                }
            }
            
            let upcomingCount = trainingPlanManager.getUpcomingWorkouts(limit: 1).count
            if upcomingCount > 0 {
                return "\(plan.name) • Next workout scheduled"
            } else {
                return plan.name
            }
        }
        return Date.now.formatted(date: .abbreviated, time: .omitted)
    }
    
    func startTodaysWorkout() async throws {
        let todaysWorkouts = trainingPlanManager.getTodaysWorkouts()
        guard let firstIncomplete = todaysWorkouts.first(where: { !$0.isCompleted }) else { return }
        
        let template = try await workoutTemplateManager.getWorkoutTemplate(id: firstIncomplete.workoutTemplateId)
        
        // Store scheduled workout reference for WorkoutStartView
        scheduledWorkoutToStart = firstIncomplete
        
        // Small delay to ensure any pending presentations complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Show WorkoutStartView (preview, notes, etc.)
        workoutToStart = template
    }
    
    func getTodaysWorkouts() -> Bool {
        trainingPlanManager.getTodaysWorkouts().contains(where: { !$0.isCompleted })
    }
}
