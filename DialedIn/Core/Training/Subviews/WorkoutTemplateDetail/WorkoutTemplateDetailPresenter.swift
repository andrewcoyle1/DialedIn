//
//  WorkoutTemplateDetailPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutTemplateDetailPresenter {
    private let interactor: WorkoutTemplateDetailInteractor
    private let router: WorkoutTemplateDetailRouter

    private(set) var isDeleting: Bool = false

    var isBookmarked: Bool = false
    var isFavourited: Bool = false
        
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    var activeSession: WorkoutSessionModel? {
        interactor.activeSession
    }
    
    init(
        interactor: WorkoutTemplateDetailInteractor,
        router: WorkoutTemplateDetailRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func loadInitialState(template: WorkoutTemplateModel) {
        let user = currentUser
        // Always treat authored templates as bookmarked
        let isAuthor = user?.userId == template.authorId
    }

    func showDeleteConfirmation(workoutTemplate: WorkoutTemplateModel) {
        router.showAlert(title: "Delete Workout", subtitle: "Are you sure you want to delete '\(workoutTemplate.name)'? This action cannot be undone.", buttons: {
            AnyView(
                HStack {
                    Button("Delete", role: .destructive) {
                        Task {
                            await self.deleteWorkout(template: workoutTemplate, onDismiss: {
                                self.router.dismissScreen()
                            })
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
            )
        })
    }

    func deleteWorkout(template: WorkoutTemplateModel, onDismiss: @escaping () -> Void) async {
        isDeleting = true
        do {            
            // Delete the workout template
            try await interactor.deleteWorkoutTemplate(id: template.id)
            
            // Dismiss the view after successful deletion
            onDismiss()
        } catch {
            isDeleting = false
            router.showSimpleAlert(title: "Failed to delete workout", subtitle: "Please try again later")
        }
    }

    func onStartWorkoutPressed(workoutTemplate: WorkoutTemplateModel) {
        let shouldProceed = checkForActiveWorkout(
            onResumeWorkout: { [weak self] in
                Task { @MainActor in
                    self?.resumeActiveWorkout()
                }
            },
            onStartNewWorkout: { [weak self] in
                Task { @MainActor in
                    self?.performStartWorkout(workoutTemplate: workoutTemplate)
                }
            }
        )
        
        if shouldProceed {
            performStartWorkout(workoutTemplate: workoutTemplate)
        }
    }
    
    // MARK: - Active Workout Safeguard
    
    private func checkForActiveWorkout(onResumeWorkout: @escaping @Sendable () -> Void, onStartNewWorkout: @escaping @Sendable () -> Void) -> Bool {
        guard let activeSession = activeSession else {
            return true
        }
        
        router.showAlert(
            title: "Workout In Progress",
            subtitle: "You already have '\(activeSession.name)' in progress. What would you like to do?",
            buttons: {
                AnyView(
                    VStack {
                        Button("Resume Current Workout") {
                            onResumeWorkout()
                        }
                        Button("Discard & Start New", role: .destructive) {
                            onStartNewWorkout()
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                )
            }
        )
        
        return false
    }
    
    private func resumeActiveWorkout() {
        guard let activeSession = activeSession else { return }
        router.dismissEnvironment()
        router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSessionId: activeSession.id))
    }
    
    private func performStartWorkout(workoutTemplate: WorkoutTemplateModel) {
        guard let userId = currentUser?.userId else { return }
        router.showWorkoutStartModal(
            delegate: WorkoutStartDelegate(
                template: workoutTemplate,
                programId: nil,
                dayPlanId: nil,
                onStartWorkoutPressed: {
                    
                    do {
                        // Load unit preferences for all exercises in template
                        var unitPreferences: [String: ExerciseUnitPreference] = [:]
                        for exerciseTemplate in workoutTemplate.exercises {
                            let preference = self.interactor.getPreference(templateId: exerciseTemplate.exercise.id)
                            unitPreferences[exerciseTemplate.exercise.id] = preference
                        }
                        
                        // Create workout session from template
                        let session = WorkoutSessionModel(
                            authorId: userId,
                            template: workoutTemplate,
                            notes: nil,
                            scheduledWorkoutId: nil,
                            trainingPlanId: nil,
                            programId: nil,
                            dayPlanId: nil,
                            unitPreferences: unitPreferences
                        )
                        
                        // Save locally first (MainActor-isolated)
                        try self.interactor.addLocalWorkoutSession(session: session)
                        
                        self.interactor.startActiveSession(session)
                                self.router.dismissModal()
                        self.router.dismissEnvironment()
                        self.router.showWorkoutTrackerView(delegate: WorkoutTrackerDelegate(workoutSessionId: session.id))
                    } catch {
                        self.router.showSimpleAlert(title: "Unable to start workout", subtitle: "Please try again.")
                    }
                },
                onCancelPressed: {
                    self.router.dismissModal()
                }

            )
        )
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }

    func onEditWorkoutPressed(template: WorkoutTemplateModel) {
        router.showCreateWorkoutView(delegate: CreateWorkoutDelegate(workoutTemplate: template))
    }
}
