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
                            try? self.interactor.deleteActiveSession()
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
        guard activeSession != nil else { return }
        router.dismissEnvironment()
        router.showWorkoutTrackerView()
    }
    
    private func performStartWorkout(workoutTemplate: WorkoutTemplateModel) {
        router.showWorkoutStartModal(
            delegate: WorkoutStartDelegate(
                template: workoutTemplate,
                trainingProgramId: nil,
                onStartWorkoutPressed: { [weak self] in
                    guard let self else { return }
                    Task {
                        do {
                            try await self.interactor.startWorkout(for: workoutTemplate, in: nil)
                            self.router.dismissModal()
                            self.router.dismissEnvironment()
                            self.router.showWorkoutTrackerView()
                        } catch {
                            self.router.showSimpleAlert(title: "Unable to start workout", subtitle: "Please try again.")
                        }
                    }
                },
                onCancelPressed: {
                    self.router.dismissModal()
                }

            )
        )
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif

    func onDismissPressed() {
        router.dismissScreen()
    }

    func onEditWorkoutPressed(template: WorkoutTemplateModel) {
        router.showCreateWorkoutView(delegate: CreateWorkoutDelegate(workoutTemplate: template))
    }
}
