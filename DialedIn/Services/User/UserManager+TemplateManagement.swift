//
//  UserManager+TemplateManagement.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import Foundation

extension UserManager {
    
    // MARK: - Created/Bookmarked/Favourited Exercise Templates
    
    func addCreatedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.addCreatedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    func removeCreatedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeCreatedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    func addBookmarkedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.addBookmarkedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    func removeBookmarkedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeBookmarkedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    func addFavouritedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.addFavouritedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    func removeFavouritedExerciseTemplate(exerciseId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeFavouritedExerciseTemplate(userId: uid, exerciseTemplateId: exerciseId)
    }
    
    // MARK: - Created/Bookmarked/Favourited Workout Templates
    
    func addCreatedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.addCreatedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    func removeCreatedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeCreatedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    func addBookmarkedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.addBookmarkedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    func removeBookmarkedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeBookmarkedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    func addFavouritedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.addFavouritedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    func removeFavouritedWorkoutTemplate(workoutId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeFavouritedWorkoutTemplate(userId: uid, workoutTemplateId: workoutId)
    }
    
    // MARK: - Created/Bookmarked/Favourited Ingredient Templates

    func addCreatedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.addCreatedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    func removeCreatedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeCreatedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    func addBookmarkedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.addBookmarkedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    func removeBookmarkedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeBookmarkedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    func addFavouritedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.addFavouritedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    func removeFavouritedIngredientTemplate(ingredientId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeFavouritedIngredientTemplate(userId: uid, ingredientTemplateId: ingredientId)
    }

    // MARK: - Created/Bookmarked/Favourited Recipe Templates

    func addCreatedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.addCreatedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }

    func removeCreatedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeCreatedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }

    func addBookmarkedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.addBookmarkedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }

    func removeBookmarkedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeBookmarkedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }

    func addFavouritedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.addFavouritedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }

    func removeFavouritedRecipeTemplate(recipeId: String) async throws {
        let uid = try currentUserId()
        try await remote.removeFavouritedRecipeTemplate(userId: uid, recipeTemplateId: recipeId)
    }
}
