//
//  TrainingPresenter+WorkoutStart.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/02/2026.
//

import Foundation

@MainActor
extension TrainingPresenter {
    
    /// Handles workout start request by loading previous session, gym profile, and unit preferences
    func handleWorkoutStartRequest(
        template: WorkoutTemplateModel,
        programId: String? = nil,
        dayPlanId: String? = nil
    ) {
        guard let userId = currentUser?.userId else { return }
        router.showWorkoutStartModal(
            delegate: WorkoutStartDelegate(
                template: template,
                programId: programId,
                dayPlanId: dayPlanId,
                onStartWorkoutPressed: {
                    Task { @MainActor in
                        await self.startWorkoutSession(
                            template: template,
                            userId: userId,
                            programId: programId,
                            dayPlanId: dayPlanId
                        )
                    }
                },
                onCancelPressed: {
                    self.router.dismissModal()
                }
            )
        )
    }
    
    /// Creates and starts a workout session with smart progression
    private func startWorkoutSession(
        template: WorkoutTemplateModel,
        userId: String,
        programId: String?,
        dayPlanId: String?
    ) async {
        do {
            let previousSession = await loadPreviousWorkoutSession(template: template, userId: userId)
            let unitPreferences = loadUnitPreferences(for: template)
            
            let session = WorkoutSessionModel(
                authorId: userId,
                template: template,
                notes: nil,
                trainingPlanId: nil,
                programId: programId,
                dayPlanId: dayPlanId,
                previousWorkoutSession: previousSession,
                gymProfile: favouriteGymProfile,
                unitPreferences: unitPreferences
            )
            
            try interactor.updateActiveSession(session)
            
            Task {
                try? await Task.sleep(for: .seconds(0.5))
                router.dismissModal()
            }
            
            router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSessionId: session.id))
        } catch {
            router.showSimpleAlert(title: "Unable to start workout", subtitle: "Please try again.")
        }
    }
    
    /// Loads previous workout session for smart progression
    private func loadPreviousWorkoutSession(
        template: WorkoutTemplateModel,
        userId: String
    ) async -> WorkoutSessionModel? {
        
        // First try exact template ID match
        return workoutSessions.first(where: { $0.workoutTemplateId == template.id}) 
    }
    
    /// Finds a workout session with matching exercise template IDs
    private func findSessionWithMatchingExercises(
        template: WorkoutTemplateModel,
        userId: String
    ) async -> WorkoutSessionModel? {
        let currentExerciseIds = Set(template.exercises.map { $0.exercise.id })
                
        let completedSessions = workoutSessions.filter { $0.endedAt != nil }
            .sorted { ($0.endedAt ?? .distantPast) > ($1.endedAt ?? .distantPast) }
        
        for session in completedSessions {
            let sessionExerciseIds = Set(session.exercises.map { $0.templateId })
            
            if sessionExerciseIds == currentExerciseIds {
                return session
            }
        }
                return nil
    }
        
    /// Loads unit preferences for all exercises in template
    private func loadUnitPreferences(for template: WorkoutTemplateModel) -> [String: ExerciseUnitPreference] {
        var unitPreferences: [String: ExerciseUnitPreference] = [:]
        for exerciseModel in template.exercises {
            let preference = interactor.getPreference(templateId: exerciseModel.exercise.id)
            unitPreferences[exerciseModel.exercise.id] = preference
        }
        return unitPreferences
    }
}
