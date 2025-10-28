//
//  TrainingViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol TrainingInteractor {
    var currentTrainingPlan: TrainingPlan? { get }
    func getTodaysWorkouts() -> [ScheduledWorkout]
    func getUpcomingWorkouts(limit: Int) -> [ScheduledWorkout]
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel
}

extension CoreInteractor: TrainingInteractor { }

@Observable
@MainActor
class TrainingViewModel {
    
    private let interactor: TrainingInteractor
    
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
    
    init(interactor: TrainingInteractor) {
        self.interactor = interactor
    }
    
    func onNotificationsPressed() {
        showNotificationsView = true
    }
    
    var currentMenuIcon: String {
        switch presentationMode {
        case .program:
            return "calendar"
        case .workouts:
            return "dumbbell"
        case .exercises:
            return "list.bullet.rectangle.portrait"
        case .history:
            return "clock"
        }
    }
    
    var navigationSubtitle: String {
        if presentationMode == .program,
            let plan = interactor.currentTrainingPlan {
            let todaysWorkouts = interactor.getTodaysWorkouts()
            if !todaysWorkouts.isEmpty {
                let completedCount = todaysWorkouts.filter { $0.isCompleted }.count
                if completedCount == todaysWorkouts.count {
                    return "\(plan.name) • Today's workout complete ✓"
                } else {
                    return "\(plan.name) • Workout scheduled for today"
                }
            }
            
            let upcomingCount = interactor.getUpcomingWorkouts(limit: 1).count
            if upcomingCount > 0 {
                return "\(plan.name) • Next workout scheduled"
            } else {
                return plan.name
            }
        }
        return Date.now.formatted(date: .abbreviated, time: .omitted)
    }
    
    func startTodaysWorkout() async throws {
        let todaysWorkouts = interactor.getTodaysWorkouts()
        guard let firstIncomplete = todaysWorkouts.first(where: { !$0.isCompleted }) else { return }
        
        let template = try await interactor.getWorkoutTemplate(id: firstIncomplete.workoutTemplateId)
        
        // Store scheduled workout reference for WorkoutStartView
        scheduledWorkoutToStart = firstIncomplete
        
        // Small delay to ensure any pending presentations complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Show WorkoutStartView (preview, notes, etc.)
        workoutToStart = template
    }
    
    func getTodaysWorkouts() -> Bool {
        interactor.getTodaysWorkouts().contains(where: { !$0.isCompleted })
    }
    
    func handleWorkoutStartRequest(template: WorkoutTemplateModel, scheduledWorkout: ScheduledWorkout?) {
        workoutToStart = template
        scheduledWorkoutToStart = scheduledWorkout
    }
}
