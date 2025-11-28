//
//  WorkoutStartPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutStartPresenter {
    private let interactor: WorkoutStartInteractor
    private let router: WorkoutStartRouter

    init(
        interactor: WorkoutStartInteractor,
        router: WorkoutStartRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    var workoutNotes = ""
    var isStarting = false
    private(set) var createdSession: WorkoutSessionModel?
    
    var activeSession: WorkoutSessionModel? {
        interactor.activeSession
    }
    
    var currentTrainingPlan: TrainingPlan? {
        interactor.currentTrainingPlan
    }
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    func estimatedTime(template: WorkoutTemplateModel) -> String {
        // Rough estimate: 3-4 minutes per exercise
        let minutes = template.exercises.count * 4
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }
    
    func primaryMuscleGroup(template: WorkoutTemplateModel) -> String {
        // Find the most common exercise category
        let categories = template.exercises.map { $0.type }
        let categoryFrequency = Dictionary(grouping: categories, by: { $0 })
            .mapValues { $0.count }
        
        let mostCommon = categoryFrequency.max(by: { $0.value < $1.value })?.key
        return mostCommon?.description ?? "Mixed"
    }
    
    func startWorkout(template: WorkoutTemplateModel, scheduledWorkout: ScheduledWorkout?) {
        guard let userId = currentUser?.userId else {
            return
        }
        
        Task {
            isStarting = true
            
            do {
                // Create workout session from template
                let session = WorkoutSessionModel(
                    authorId: userId,
                    template: template,
                    notes: workoutNotes.isEmpty ? nil : workoutNotes,
                    scheduledWorkoutId: scheduledWorkout?.id,
                    trainingPlanId: scheduledWorkout != nil ? currentTrainingPlan?.planId : nil
                )
                
                // Save locally first (MainActor-isolated)
                try interactor.addLocalWorkoutSession(session: session)
                
                await MainActor.run {
                    createdSession = session
                    isStarting = false
                }
                
                // Small delay before presenting next screen
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                
                await MainActor.run {
                    interactor.startActiveSession(session)
                    router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSession: session))
                }
                
            } catch {
                await MainActor.run {
                    isStarting = false
                    // Handle error - could show an alert
                }
            }
        }
    }

    func dismissScreen() {
        router.dismissScreen()
    }
}
