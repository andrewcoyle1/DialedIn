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

@MainActor
protocol TrainingRouter {
    func showNotificationsView()
    func showDevSettingsView()
    func showWorkoutStartView(delegate: WorkoutStartViewDelegate)
    func showProgramManagementView()
    func showProgressDashboardView()
    func showStrengthProgressView()
    func showWorkoutHeatmapView()
}

extension CoreRouter: TrainingRouter { }

@Observable
@MainActor
class TrainingViewModel {
    
    private let interactor: TrainingInteractor
    private let router: TrainingRouter

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
    var scheduledWorkoutToStart: ScheduledWorkout?
    var showCreateExercise: Bool = false
    var showCreateWorkout: Bool = false
    var selectedHistorySession: WorkoutSessionModel?
    
    init(
        interactor: TrainingInteractor,
        router: TrainingRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onNotificationsPressed() {
        router.showNotificationsView()
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
    
    func startTodaysWorkout() {
        Task {
            do {
                let todaysWorkouts = interactor.getTodaysWorkouts()
                guard let firstIncomplete = todaysWorkouts.first(where: { !$0.isCompleted }) else { return }

                let template = try await interactor.getWorkoutTemplate(id: firstIncomplete.workoutTemplateId)

                // Store scheduled workout reference for WorkoutStartView
                scheduledWorkoutToStart = firstIncomplete

                // Small delay to ensure any pending presentations complete
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

                // Show WorkoutStartView (preview, notes, etc.)
                handleWorkoutStartRequest(template: template, scheduledWorkout: scheduledWorkoutToStart)
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func getTodaysWorkouts() -> Bool {
        interactor.getTodaysWorkouts().contains(where: { !$0.isCompleted })
    }
    
    func handleWorkoutStartRequest(template: WorkoutTemplateModel, scheduledWorkout: ScheduledWorkout?) {
        onStartWorkout(delegate: WorkoutStartViewDelegate(template: template, scheduledWorkout: scheduledWorkout))
    }

    func onStartWorkout(delegate: WorkoutStartViewDelegate) {
        router.showWorkoutStartView(delegate: delegate)
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
}

enum TrainingPresentationMode {
    case program
    case workouts
    case exercises
    case history
}

enum ActiveSheet: Identifiable {
    case programPicker
    case progressDashboard
    case strengthProgress
    case workoutHeatmap
    case addGoal
    
    var id: String {
        switch self {
        case .programPicker: return "programPicker"
        case .progressDashboard: return "progressDashboard"
        case .strengthProgress: return "strengthProgress"
        case .workoutHeatmap: return "workoutHeatmap"
        case .addGoal: return "addGoal"
        }
    }
    
    var eventParameters: [String: Any] {
        let sheet = self
        let params: [String: Any] = [
            "program_sheet": sheet.id
        ]
        
        return params
    }
}
