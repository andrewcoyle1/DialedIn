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
        isBookmarked = isAuthor || (user?.bookmarkedWorkoutTemplateIds?.contains(template.id) ?? false) || (user?.createdWorkoutTemplateIds?.contains(template.id) ?? false)
        isFavourited = user?.favouritedWorkoutTemplateIds?.contains(template.id) ?? false
    }
    
    func onBookmarkPressed(template: WorkoutTemplateModel) async {
        let newState = !isBookmarked
        do {
            // If unbookmarking and currently favourited, unfavourite first to enforce rule
            if !newState && isFavourited {
                try await interactor.favouriteWorkoutTemplate(id: template.id, isFavourited: false)
                isFavourited = false
                // Remove from user's favourited list
                try await interactor.removeFavouritedWorkoutTemplate(workoutId: template.id)
            }
            try await interactor.bookmarkWorkoutTemplate(id: template.id, isBookmarked: newState)
            if newState {
                try await interactor.addBookmarkedWorkoutTemplate(workoutId: template.id)
            } else {
                try await interactor.removeBookmarkedWorkoutTemplate(workoutId: template.id)
            }
            isBookmarked = newState
        } catch {
            router.showSimpleAlert(title: "Failed to update bookmark status", subtitle: "Please try again later")
        }
    }
    
    func onFavoritePressed(template: WorkoutTemplateModel) async {
        let newState = !isFavourited
        do {
            // If favouriting and not bookmarked, bookmark first to enforce rule
            if newState && !isBookmarked {
                try await interactor.bookmarkWorkoutTemplate(id: template.id, isBookmarked: true)
                try await interactor.addBookmarkedWorkoutTemplate(workoutId: template.id)
                isBookmarked = true
            }
            try await interactor.favouriteWorkoutTemplate(id: template.id, isFavourited: newState)
            if newState {
                try await interactor.addFavouritedWorkoutTemplate(workoutId: template.id)
            } else {
                try await interactor.removeFavouritedWorkoutTemplate(workoutId: template.id)
            }
            isFavourited = newState
        } catch {
            router.showSimpleAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
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
            // Remove from user's created templates list
            try await interactor.removeCreatedWorkoutTemplate(workoutId: template.id)
            
            // Remove from bookmarked if bookmarked
            if isBookmarked {
                try await interactor.removeBookmarkedWorkoutTemplate(workoutId: template.id)
            }
            
            // Remove from favourited if favourited
            if isFavourited {
                try await interactor.removeFavouritedWorkoutTemplate(workoutId: template.id)
            }
            
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
        router.showWorkoutStartView(delegate: WorkoutStartDelegate(template: workoutTemplate, scheduledWorkout: nil))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    func onEditWorkoutPressed(template: WorkoutTemplateModel) {
        router.showCreateWorkoutView(delegate: CreateWorkoutDelegate(workoutTemplate: template))
    }
}
