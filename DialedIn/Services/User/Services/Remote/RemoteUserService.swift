//
//  RemoteUserService.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/15/24.
//

import SwiftUI

protocol RemoteUserService: Sendable {
    func saveUser(user: UserModel, image: PlatformImage?) async throws
    func markUnanonymous(userId: String, email: String?) async throws
    func updateFirstName(userId: String, firstName: String) async throws
    func updateLastName(userId: String, lastName: String) async throws
    func updateDateOfBirth(userId: String, dateOfBirth: Date) async throws
    func updateGender(userId: String, gender: Gender) async throws
    func updateProfileImageUrl(userId: String, url: String?) async throws
    func updateLastSignInDate(userId: String) async throws
    func markOnboardingCompleted(userId: String) async throws
    // MARK: - Goal Settings
    func updateGoalSettings(userId: String, objective: String, targetWeightKilograms: Double, weeklyChangeKilograms: Double) async throws
    func addCreatedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws
    func removeCreatedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws
    func addBookmarkedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws
    func removeBookmarkedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws
    func addFavouritedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws
    func removeFavouritedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws
    func addCreatedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws
    func removeCreatedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws
    func addBookmarkedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws
    func removeBookmarkedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws
    func addFavouritedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws
    func removeFavouritedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws
    func addCreatedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws
    func removeCreatedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws
    func addBookmarkedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws
    func removeBookmarkedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws
    func addFavouritedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws
    func removeFavouritedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws
    func addCreatedRecipeTemplate(userId: String, recipeTemplateId: String) async throws
    func removeCreatedRecipeTemplate(userId: String, recipeTemplateId: String) async throws
    func addBookmarkedRecipeTemplate(userId: String, recipeTemplateId: String) async throws
    func removeBookmarkedRecipeTemplate(userId: String, recipeTemplateId: String) async throws
    func addFavouritedRecipeTemplate(userId: String, recipeTemplateId: String) async throws
    func removeFavouritedRecipeTemplate(userId: String, recipeTemplateId: String) async throws
    func blockUser(currentUserId: String, blockedUserId: String) async throws
    func unblockUser(currentUserId: String, blockedUserId: String) async throws
    func deleteUser(userId: String) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    // MARK: - Consents
    func updateHealthConsents(userId: String, disclaimerVersion: String, privacyVersion: String, acceptedAt: Date) async throws
}
