//
//  WorkoutTemplateDetailViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class WorkoutTemplateDetailViewModel {
    private let userManager: UserManager
    private let workoutTemplateManager: WorkoutTemplateManager
    private let workoutSessionManager: WorkoutSessionManager
    
    private(set) var isDeleting: Bool = false

    var showStartSessionSheet: Bool = false
    var showAlert: AnyAppAlert?
    var showEditSheet: Bool = false
    var showDeleteConfirmation: Bool = false
    var isBookmarked: Bool = false
    var isFavourited: Bool = false
    
    #if DEBUG || MOCK
    var showDebugView: Bool = false
    #endif
    
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    init(
        container: DependencyContainer
    ) {
        self.userManager = container.resolve(UserManager.self)!
        self.workoutTemplateManager = container.resolve(WorkoutTemplateManager.self)!
        self.workoutSessionManager = container.resolve(WorkoutSessionManager.self)!
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
                try await workoutTemplateManager.favouriteWorkoutTemplate(id: template.id, isFavourited: false)
                isFavourited = false
                // Remove from user's favourited list
                try await userManager.removeFavouritedWorkoutTemplate(workoutId: template.id)
            }
            try await workoutTemplateManager.bookmarkWorkoutTemplate(id: template.id, isBookmarked: newState)
            if newState {
                try await userManager.addBookmarkedWorkoutTemplate(workoutId: template.id)
            } else {
                try await userManager.removeBookmarkedWorkoutTemplate(workoutId: template.id)
            }
            isBookmarked = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update bookmark status", subtitle: "Please try again later")
        }
    }
    
    func onFavoritePressed(template: WorkoutTemplateModel) async {
        let newState = !isFavourited
        do {
            // If favouriting and not bookmarked, bookmark first to enforce rule
            if newState && !isBookmarked {
                try await workoutTemplateManager.bookmarkWorkoutTemplate(id: template.id, isBookmarked: true)
                try await userManager.addBookmarkedWorkoutTemplate(workoutId: template.id)
                isBookmarked = true
            }
            try await workoutTemplateManager.favouriteWorkoutTemplate(id: template.id, isFavourited: newState)
            if newState {
                try await userManager.addFavouritedWorkoutTemplate(workoutId: template.id)
            } else {
                try await userManager.removeFavouritedWorkoutTemplate(workoutId: template.id)
            }
            isFavourited = newState
        } catch {
            showAlert = AnyAppAlert(title: "Failed to update favourite status", subtitle: "Please try again later")
        }
    }
    
    func deleteWorkout(template: WorkoutTemplateModel, onDismiss: @escaping () -> Void) async {
        isDeleting = true
        do {
            // Remove from user's created templates list
            try await userManager.removeCreatedWorkoutTemplate(workoutId: template.id)
            
            // Remove from bookmarked if bookmarked
            if isBookmarked {
                try await userManager.removeBookmarkedWorkoutTemplate(workoutId: template.id)
            }
            
            // Remove from favourited if favourited
            if isFavourited {
                try await userManager.removeFavouritedWorkoutTemplate(workoutId: template.id)
            }
            
            // Delete the workout template
            try await workoutTemplateManager.deleteWorkoutTemplate(id: template.id)
            
            // Dismiss the view after successful deletion
            onDismiss()
        } catch {
            isDeleting = false
            showAlert = AnyAppAlert(title: "Failed to delete workout", subtitle: "Please try again later")
        }
    }
}
