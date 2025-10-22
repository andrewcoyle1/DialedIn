//
//  WorkoutCalendarViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 22/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutCalendarViewModel {
    private let workoutTemplateManager: WorkoutTemplateManager
    private let workoutSessionManager: WorkoutSessionManager
    private let trainingPlanManager: TrainingPlanManager
    private let onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)?
    private let onWorkoutStartRequested: ((WorkoutTemplateModel, ScheduledWorkout?) -> Void)?

    var isShowingCalendar: Bool = true
    var collapsedSubtitle: String = "No sessions planned yet — tap to plan"
    private(set) var scheduledWorkouts: [ScheduledWorkout] = []
    var selectedDate: Date?
    var showWorkoutMenu: Bool = false
    private(set) var workoutsForMenu: [ScheduledWorkout] = []
    var showAlert: AnyAppAlert?
    
    var trainingPlan: TrainingPlan? {
        trainingPlanManager.currentTrainingPlan
    }
    
    init(
        container: DependencyContainer,
        onSessionSelectionChanged: ((WorkoutSessionModel) -> Void)? = nil,
        onWorkoutStartRequested: ((WorkoutTemplateModel, ScheduledWorkout?) -> Void)? = nil
    ) {
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
        self.trainingPlanManager = container.resolve(TrainingPlanManager.self)!
        self.onSessionSelectionChanged = onSessionSelectionChanged
        self.onWorkoutStartRequested = onWorkoutStartRequested
    }
    
    func onCalendarToggled() {
        withAnimation(.easeInOut) {
            isShowingCalendar.toggle()
        }
    }
    
    func loadScheduledWorkouts() {
        guard let plan = trainingPlanManager.currentTrainingPlan else {
            scheduledWorkouts = []
            return
        }
        scheduledWorkouts = plan.weeks.flatMap { $0.scheduledWorkouts }
    }
    
    func workoutsForDate(_ date: Date) -> [ScheduledWorkout] {
        let calendar = Calendar.current
        return scheduledWorkouts.filter { workout in
            guard let scheduledDate = workout.scheduledDate else { return false }
            return calendar.isDate(scheduledDate, inSameDayAs: date)
        }
    }
    
    func handleDateTapped(_ date: Date) {
        selectedDate = date
        let workouts = workoutsForDate(date)
        
        if workouts.isEmpty {
            return
        } else if workouts.count == 1 {
            // Single workout - handle directly
            Task {
                await handleWorkoutSelection(workouts[0])
            }
        } else {
            // Multiple workouts - show menu
            workoutsForMenu = workouts
            showWorkoutMenu = true
        }
    }
    
    func handleWorkoutSelection(_ workout: ScheduledWorkout) async {
        if workout.isCompleted {
            await openCompletedSession(for: workout)
        } else {
            do {
                try await startWorkout(workout)
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func startWorkout(_ scheduledWorkout: ScheduledWorkout) async throws {
        let template = try await workoutTemplateManager.getWorkoutTemplate(id: scheduledWorkout.workoutTemplateId)
        
        // Small delay to ensure any pending presentations complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Notify parent to show WorkoutStartView
        onWorkoutStartRequested?(template, scheduledWorkout)
    }
    
    func openCompletedSession(for scheduledWorkout: ScheduledWorkout) async {
        guard let sessionId = scheduledWorkout.completedSessionId else { return }
        do {
            let session = try await workoutSessionManager.getWorkoutSession(id: sessionId)
            await MainActor.run {
                onSessionSelectionChanged?(session)
            }
        } catch {
            showAlert = AnyAppAlert(error: error)
        }
    }
}
