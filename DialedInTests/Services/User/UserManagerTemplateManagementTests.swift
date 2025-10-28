//
//  UserManagerTemplateManagementTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation

@MainActor
struct UserManagerTemplateManagementTests {
    
    // MARK: - Exercise Template Tests
    
    @Test("Test Add Created Exercise Template Succeeds")
    func testAddCreatedExerciseTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let exerciseId = String.random
        try await manager.addCreatedExerciseTemplate(exerciseId: exerciseId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Created Exercise Template Throws When No Current User")
    func testAddCreatedExerciseTemplateThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.addCreatedExerciseTemplate(exerciseId: "exercise123")
        }
    }
    
    @Test("Test Remove Created Exercise Template Succeeds")
    func testRemoveCreatedExerciseTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let exerciseId = String.random
        try await manager.removeCreatedExerciseTemplate(exerciseId: exerciseId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Bookmarked Exercise Template Succeeds")
    func testAddBookmarkedExerciseTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let exerciseId = String.random
        try await manager.addBookmarkedExerciseTemplate(exerciseId: exerciseId)
        
        // No error should be thrown
    }
    
    @Test("Test Remove Bookmarked Exercise Template Succeeds")
    func testRemoveBookmarkedExerciseTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let exerciseId = String.random
        try await manager.removeBookmarkedExerciseTemplate(exerciseId: exerciseId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Favourited Exercise Template Succeeds")
    func testAddFavouritedExerciseTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let exerciseId = String.random
        try await manager.addFavouritedExerciseTemplate(exerciseId: exerciseId)
        
        // No error should be thrown
    }
    
    @Test("Test Remove Favourited Exercise Template Succeeds")
    func testRemoveFavouritedExerciseTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let exerciseId = String.random
        try await manager.removeFavouritedExerciseTemplate(exerciseId: exerciseId)
        
        // No error should be thrown
    }
    
    // MARK: - Workout Template Tests
    
    @Test("Test Add Created Workout Template Succeeds")
    func testAddCreatedWorkoutTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let workoutId = String.random
        try await manager.addCreatedWorkoutTemplate(workoutId: workoutId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Created Workout Template Throws When No Current User")
    func testAddCreatedWorkoutTemplateThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.addCreatedWorkoutTemplate(workoutId: "workout123")
        }
    }
    
    @Test("Test Remove Created Workout Template Succeeds")
    func testRemoveCreatedWorkoutTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let workoutId = String.random
        try await manager.removeCreatedWorkoutTemplate(workoutId: workoutId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Bookmarked Workout Template Succeeds")
    func testAddBookmarkedWorkoutTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let workoutId = String.random
        try await manager.addBookmarkedWorkoutTemplate(workoutId: workoutId)
        
        // No error should be thrown
    }
    
    @Test("Test Remove Bookmarked Workout Template Succeeds")
    func testRemoveBookmarkedWorkoutTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let workoutId = String.random
        try await manager.removeBookmarkedWorkoutTemplate(workoutId: workoutId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Favourited Workout Template Succeeds")
    func testAddFavouritedWorkoutTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let workoutId = String.random
        try await manager.addFavouritedWorkoutTemplate(workoutId: workoutId)
        
        // No error should be thrown
    }
    
    @Test("Test Remove Favourited Workout Template Succeeds")
    func testRemoveFavouritedWorkoutTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let workoutId = String.random
        try await manager.removeFavouritedWorkoutTemplate(workoutId: workoutId)
        
        // No error should be thrown
    }
    
    // MARK: - Ingredient Template Tests
    
    @Test("Test Add Created Ingredient Template Succeeds")
    func testAddCreatedIngredientTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let ingredientId = String.random
        try await manager.addCreatedIngredientTemplate(ingredientId: ingredientId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Created Ingredient Template Throws When No Current User")
    func testAddCreatedIngredientTemplateThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.addCreatedIngredientTemplate(ingredientId: "ingredient123")
        }
    }
    
    @Test("Test Remove Created Ingredient Template Succeeds")
    func testRemoveCreatedIngredientTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let ingredientId = String.random
        try await manager.removeCreatedIngredientTemplate(ingredientId: ingredientId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Bookmarked Ingredient Template Succeeds")
    func testAddBookmarkedIngredientTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let ingredientId = String.random
        try await manager.addBookmarkedIngredientTemplate(ingredientId: ingredientId)
        
        // No error should be thrown
    }
    
    @Test("Test Remove Bookmarked Ingredient Template Succeeds")
    func testRemoveBookmarkedIngredientTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let ingredientId = String.random
        try await manager.removeBookmarkedIngredientTemplate(ingredientId: ingredientId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Favourited Ingredient Template Succeeds")
    func testAddFavouritedIngredientTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let ingredientId = String.random
        try await manager.addFavouritedIngredientTemplate(ingredientId: ingredientId)
        
        // No error should be thrown
    }
    
    @Test("Test Remove Favourited Ingredient Template Succeeds")
    func testRemoveFavouritedIngredientTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let ingredientId = String.random
        try await manager.removeFavouritedIngredientTemplate(ingredientId: ingredientId)
        
        // No error should be thrown
    }
    
    // MARK: - Recipe Template Tests
    
    @Test("Test Add Created Recipe Template Succeeds")
    func testAddCreatedRecipeTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let recipeId = String.random
        try await manager.addCreatedRecipeTemplate(recipeId: recipeId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Created Recipe Template Throws When No Current User")
    func testAddCreatedRecipeTemplateThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.addCreatedRecipeTemplate(recipeId: "recipe123")
        }
    }
    
    @Test("Test Remove Created Recipe Template Succeeds")
    func testRemoveCreatedRecipeTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let recipeId = String.random
        try await manager.removeCreatedRecipeTemplate(recipeId: recipeId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Bookmarked Recipe Template Succeeds")
    func testAddBookmarkedRecipeTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let recipeId = String.random
        try await manager.addBookmarkedRecipeTemplate(recipeId: recipeId)
        
        // No error should be thrown
    }
    
    @Test("Test Remove Bookmarked Recipe Template Succeeds")
    func testRemoveBookmarkedRecipeTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let recipeId = String.random
        try await manager.removeBookmarkedRecipeTemplate(recipeId: recipeId)
        
        // No error should be thrown
    }
    
    @Test("Test Add Favourited Recipe Template Succeeds")
    func testAddFavouritedRecipeTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let recipeId = String.random
        try await manager.addFavouritedRecipeTemplate(recipeId: recipeId)
        
        // No error should be thrown
    }
    
    @Test("Test Remove Favourited Recipe Template Succeeds")
    func testRemoveFavouritedRecipeTemplateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let recipeId = String.random
        try await manager.removeFavouritedRecipeTemplate(recipeId: recipeId)
        
        // No error should be thrown
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Test Exercise Template Management With Remote Error")
    func testExerciseTemplateManagementWithRemoteError() async {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser, showError: true)
        let manager = UserManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.addCreatedExerciseTemplate(exerciseId: "exercise123")
        }
    }
    
    @Test("Test Workout Template Management With Remote Error")
    func testWorkoutTemplateManagementWithRemoteError() async {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser, showError: true)
        let manager = UserManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.addCreatedWorkoutTemplate(workoutId: "workout123")
        }
    }
    
    @Test("Test Ingredient Template Management With Remote Error")
    func testIngredientTemplateManagementWithRemoteError() async {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser, showError: true)
        let manager = UserManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.addCreatedIngredientTemplate(ingredientId: "ingredient123")
        }
    }
    
    @Test("Test Recipe Template Management With Remote Error")
    func testRecipeTemplateManagementWithRemoteError() async {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser, showError: true)
        let manager = UserManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.addCreatedRecipeTemplate(recipeId: "recipe123")
        }
    }
}
