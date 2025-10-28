//
//  ExerciseTemplateManagerTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation

// swiftlint:disable:next type_body_length
struct ExerciseTemplateManagerTests {
    
    // MARK: - Local Operations Tests
    
    @Test("Test Get All Local Exercise Templates")
    func testGetAllLocalExerciseTemplates() throws {
        let mockExercises = ExerciseTemplateModel.mocks
        let services = MockExerciseTemplateServices(exercises: mockExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let exercises = try manager.getAllLocalExerciseTemplates()
        
        #expect(exercises.count == mockExercises.count)
    }
    
    @Test("Test Get Local Exercise Template By ID")
    func testGetLocalExerciseTemplateById() throws {
        let mockExercises = ExerciseTemplateModel.mocks
        let services = MockExerciseTemplateServices(exercises: mockExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let firstExercise = mockExercises[0]
        let retrieved = try manager.getLocalExerciseTemplate(id: firstExercise.id)
        
        #expect(retrieved.id == firstExercise.id)
        #expect(retrieved.name == firstExercise.name)
    }
    
    @Test("Test Get Local Exercise Template Throws Error For Invalid ID")
    func testGetLocalExerciseTemplateThrowsErrorForInvalidId() {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        #expect(throws: Error.self) {
            try manager.getLocalExerciseTemplate(id: "non-existent-id")
        }
    }
    
    @Test("Test Get Local Exercise Templates With Multiple IDs")
    func testGetLocalExerciseTemplatesWithMultipleIds() throws {
        let mockExercises = ExerciseTemplateModel.mocks
        let services = MockExerciseTemplateServices(exercises: mockExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let idsToRetrieve = [mockExercises[0].id, mockExercises[1].id, mockExercises[2].id]
        let retrieved = try manager.getLocalExerciseTemplates(ids: idsToRetrieve)
        
        #expect(retrieved.count == 3)
        #expect(retrieved.map { $0.id }.allSatisfy { idsToRetrieve.contains($0) })
    }
    
    @Test("Test Get Local Exercise Templates With Empty IDs Array")
    func testGetLocalExerciseTemplatesWithEmptyIdsArray() throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let retrieved = try manager.getLocalExerciseTemplates(ids: [])
        
        #expect(retrieved.isEmpty)
    }
    
    @Test("Test Get System Exercise Templates")
    func testGetSystemExerciseTemplates() throws {
        let systemExercise = ExerciseTemplateModel(
            exerciseId: "system-1",
            name: "System Exercise",
            isSystemExercise: true,
            dateCreated: Date(),
            dateModified: Date()
        )
        let userExercise = ExerciseTemplateModel(
            exerciseId: "user-1",
            name: "User Exercise",
            isSystemExercise: false,
            dateCreated: Date(),
            dateModified: Date()
        )
        
        let exercises = [systemExercise, userExercise]
        let services = MockExerciseTemplateServices(exercises: exercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let systemExercises = try manager.getSystemExerciseTemplates()
        
        #expect(systemExercises.count == 1)
        #expect(systemExercises[0].isSystemExercise == true)
        #expect(systemExercises[0].id == "system-1")
    }
    
    @Test("Test Add Local Exercise Template")
    func testAddLocalExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let newExercise = ExerciseTemplateModel(
            exerciseId: "new-exercise",
            name: "New Exercise",
            type: .dumbbell,
            muscleGroups: [.chest],
            dateCreated: Date(),
            dateModified: Date()
        )
        
        try await manager.addLocalExerciseTemplate(exercise: newExercise)
        
        // If no error is thrown, the add was successful
        #expect(true)
    }
    
    // MARK: - Remote Operations Tests
    
    @Test("Test Create Exercise Template")
    func testCreateExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let newExercise = ExerciseTemplateModel(
            exerciseId: String.random,
            name: "New Exercise",
            type: .barbell,
            muscleGroups: [.back, .arms],
            dateCreated: Date(),
            dateModified: Date()
        )
        
        try await manager.createExerciseTemplate(exercise: newExercise, image: nil)
        
        // If no error is thrown, the creation was successful
        #expect(true)
    }
    
    @Test("Test Get Exercise Template From Remote")
    func testGetExerciseTemplateFromRemote() async throws {
        let mockExercises = ExerciseTemplateModel.mocks
        let services = MockExerciseTemplateServices(exercises: mockExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let exerciseId = mockExercises[0].id
        let retrieved = try await manager.getExerciseTemplate(id: exerciseId)
        
        #expect(retrieved.id == exerciseId)
    }
    
    @Test("Test Get Exercise Template Throws Error For Invalid ID")
    func testGetExerciseTemplateThrowsErrorForInvalidId() async {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        await #expect(throws: Error.self) {
            try await manager.getExerciseTemplate(id: "non-existent-id")
        }
    }
    
    @Test("Test Get Exercise Templates From Remote")
    func testGetExerciseTemplatesFromRemote() async throws {
        let mockExercises = ExerciseTemplateModel.mocks
        let services = MockExerciseTemplateServices(exercises: mockExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let ids = mockExercises.prefix(3).map { $0.id }
        let retrieved = try await manager.getExerciseTemplates(ids: ids)
        
        #expect(retrieved.count == 3)
        #expect(retrieved.allSatisfy { exercise in ids.contains(exercise.id) })
    }
    
    @Test("Test Get Exercise Templates With Limit")
    func testGetExerciseTemplatesWithLimit() async throws {
        let mockExercises = ExerciseTemplateModel.mocks
        let services = MockExerciseTemplateServices(exercises: mockExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let ids = mockExercises.map { $0.id }
        let limit = 5
        let retrieved = try await manager.getExerciseTemplates(ids: ids, limitTo: limit)
        
        #expect(retrieved.count <= limit)
        #expect(retrieved.count == min(limit, mockExercises.count))
    }
    
    @Test("Test Get Exercise Templates By Name")
    func testGetExerciseTemplatesByName() async throws {
        let exercises = [
            ExerciseTemplateModel(
                exerciseId: "1",
                name: "Bench Press",
                dateCreated: Date(),
                dateModified: Date()
            ),
            ExerciseTemplateModel(
                exerciseId: "2",
                name: "Dumbbell Press",
                dateCreated: Date(),
                dateModified: Date()
            ),
            ExerciseTemplateModel(
                exerciseId: "3",
                name: "Squat",
                dateCreated: Date(),
                dateModified: Date()
            )
        ]
        let services = MockExerciseTemplateServices(exercises: exercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let retrieved = try await manager.getExerciseTemplatesByName(name: "Press")
        
        #expect(retrieved.count == 2)
        #expect(retrieved.allSatisfy { $0.name.contains("Press") })
    }
    
    @Test("Test Get Exercise Templates For Author")
    func testGetExerciseTemplatesForAuthor() async throws {
        let exercises = [
            ExerciseTemplateModel(
                exerciseId: "1",
                authorId: "author-1",
                name: "Exercise 1",
                dateCreated: Date(),
                dateModified: Date()
            ),
            ExerciseTemplateModel(
                exerciseId: "2",
                authorId: "author-1",
                name: "Exercise 2",
                dateCreated: Date(),
                dateModified: Date()
            ),
            ExerciseTemplateModel(
                exerciseId: "3",
                authorId: "author-2",
                name: "Exercise 3",
                dateCreated: Date(),
                dateModified: Date()
            )
        ]
        let services = MockExerciseTemplateServices(exercises: exercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let retrieved = try await manager.getExerciseTemplatesForAuthor(authorId: "author-1")
        
        #expect(retrieved.count == 2)
        #expect(retrieved.allSatisfy { $0.authorId == "author-1" })
    }
    
    @Test("Test Get Top Exercise Templates By Clicks")
    func testGetTopExerciseTemplatesByClicks() async throws {
        let exercises = [
            ExerciseTemplateModel(
                exerciseId: "1",
                name: "Popular Exercise",
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 100
            ),
            ExerciseTemplateModel(
                exerciseId: "2",
                name: "Less Popular",
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 50
            ),
            ExerciseTemplateModel(
                exerciseId: "3",
                name: "Least Popular",
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 10
            )
        ]
        
        let services = MockExerciseTemplateServices(exercises: exercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let top = try await manager.getTopExerciseTemplatesByClicks(limitTo: 2)
        
        #expect(top.count == 2)
        // Should be sorted by clicks descending
        #expect((top[0].clickCount ?? 0) >= (top[1].clickCount ?? 0))
        #expect(top[0].clickCount == 100)
        #expect(top[1].clickCount == 50)
    }
    
    @Test("Test Get Top Exercise Templates With Different Limit")
    func testGetTopExerciseTemplatesWithDifferentLimit() async throws {
        let mockExercises = ExerciseTemplateModel.mocks
        let services = MockExerciseTemplateServices(exercises: mockExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let limit = 3
        let top = try await manager.getTopExerciseTemplatesByClicks(limitTo: limit)
        
        #expect(top.count <= limit)
    }
    
    // MARK: - Interaction Operations Tests
    
    @Test("Test Increment Exercise Template Interaction")
    func testIncrementExerciseTemplateInteraction() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let exerciseId = ExerciseTemplateModel.mocks[0].id
        try await manager.incrementExerciseTemplateInteraction(id: exerciseId)
        
        // If no error is thrown, the increment was successful
        #expect(true)
    }
    
    @Test("Test Remove Author ID From Exercise Template")
    func testRemoveAuthorIdFromExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let exerciseId = ExerciseTemplateModel.mocks[0].id
        try await manager.removeAuthorIdFromExerciseTemplate(id: exerciseId)
        
        // If no error is thrown, the operation was successful
        #expect(true)
    }
    
    @Test("Test Remove Author ID From All Exercise Templates")
    func testRemoveAuthorIdFromAllExerciseTemplates() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let authorId = "test-author"
        try await manager.removeAuthorIdFromAllExerciseTemplates(id: authorId)
        
        // If no error is thrown, the operation was successful
        #expect(true)
    }
    
    @Test("Test Bookmark Exercise Template")
    func testBookmarkExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let exerciseId = ExerciseTemplateModel.mocks[0].id
        try await manager.bookmarkExerciseTemplate(id: exerciseId, isBookmarked: true)
        
        // If no error is thrown, the bookmark was successful
        #expect(true)
    }
    
    @Test("Test Unbookmark Exercise Template")
    func testUnbookmarkExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let exerciseId = ExerciseTemplateModel.mocks[0].id
        try await manager.bookmarkExerciseTemplate(id: exerciseId, isBookmarked: false)
        
        // If no error is thrown, the unbookmark was successful
        #expect(true)
    }
    
    @Test("Test Favourite Exercise Template")
    func testFavouriteExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let exerciseId = ExerciseTemplateModel.mocks[0].id
        try await manager.favouriteExerciseTemplate(id: exerciseId, isFavourited: true)
        
        // If no error is thrown, the favourite was successful
        #expect(true)
    }
    
    @Test("Test Unfavourite Exercise Template")
    func testUnfavouriteExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let exerciseId = ExerciseTemplateModel.mocks[0].id
        try await manager.favouriteExerciseTemplate(id: exerciseId, isFavourited: false)
        
        // If no error is thrown, the unfavourite was successful
        #expect(true)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Test Get All Local Exercise Templates Throws Error When Service Fails")
    func testGetAllLocalExerciseTemplatesThrowsErrorWhenServiceFails() {
        let services = MockExerciseTemplateServices(showError: true)
        let manager = ExerciseTemplateManager(services: services)
        
        #expect(throws: URLError.self) {
            try manager.getAllLocalExerciseTemplates()
        }
    }
    
    @Test("Test Get Local Exercise Template Throws Error When Service Fails")
    func testGetLocalExerciseTemplateThrowsErrorWhenServiceFails() {
        let services = MockExerciseTemplateServices(showError: true)
        let manager = ExerciseTemplateManager(services: services)
        
        #expect(throws: URLError.self) {
            try manager.getLocalExerciseTemplate(id: "test-id")
        }
    }
    
    @Test("Test Create Exercise Template Throws Error When Service Fails")
    func testCreateExerciseTemplateThrowsErrorWhenServiceFails() async {
        let services = MockExerciseTemplateServices(showError: true)
        let manager = ExerciseTemplateManager(services: services)
        
        let exercise = ExerciseTemplateModel(
            exerciseId: "test-id",
            name: "Test Exercise",
            dateCreated: Date(),
            dateModified: Date()
        )
        
        await #expect(throws: URLError.self) {
            try await manager.createExerciseTemplate(exercise: exercise, image: nil)
        }
    }
    
    @Test("Test Get Exercise Template Throws Error When Service Fails")
    func testGetExerciseTemplateThrowsErrorWhenServiceFails() async {
        let services = MockExerciseTemplateServices(showError: true)
        let manager = ExerciseTemplateManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.getExerciseTemplate(id: "test-id")
        }
    }
    
    @Test("Test Get Exercise Templates By Name Throws Error When Service Fails")
    func testGetExerciseTemplatesByNameThrowsErrorWhenServiceFails() async {
        let services = MockExerciseTemplateServices(showError: true)
        let manager = ExerciseTemplateManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.getExerciseTemplatesByName(name: "Test")
        }
    }
    
    @Test("Test Increment Interaction Throws Error When Service Fails")
    func testIncrementInteractionThrowsErrorWhenServiceFails() async {
        let services = MockExerciseTemplateServices(showError: true)
        let manager = ExerciseTemplateManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.incrementExerciseTemplateInteraction(id: "test-id")
        }
    }
    
    @Test("Test Bookmark Exercise Template Throws Error When Service Fails")
    func testBookmarkExerciseTemplateThrowsErrorWhenServiceFails() async {
        let services = MockExerciseTemplateServices(showError: true)
        let manager = ExerciseTemplateManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.bookmarkExerciseTemplate(id: "test-id", isBookmarked: true)
        }
    }
    
    @Test("Test Favourite Exercise Template Throws Error When Service Fails")
    func testFavouriteExerciseTemplateThrowsErrorWhenServiceFails() async {
        let services = MockExerciseTemplateServices(showError: true)
        let manager = ExerciseTemplateManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.favouriteExerciseTemplate(id: "test-id", isFavourited: true)
        }
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("Test Get System Exercise Templates Returns Empty When No System Exercises")
    func testGetSystemExerciseTemplatesReturnsEmptyWhenNoSystemExercises() throws {
        let userExercises = [
            ExerciseTemplateModel(
                exerciseId: "user-1",
                name: "User Exercise 1",
                isSystemExercise: false,
                dateCreated: Date(),
                dateModified: Date()
            ),
            ExerciseTemplateModel(
                exerciseId: "user-2",
                name: "User Exercise 2",
                isSystemExercise: false,
                dateCreated: Date(),
                dateModified: Date()
            )
        ]
        
        let services = MockExerciseTemplateServices(exercises: userExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let systemExercises = try manager.getSystemExerciseTemplates()
        
        #expect(systemExercises.isEmpty)
    }
    
    @Test("Test Get All Local Exercise Templates With Empty Collection")
    func testGetAllLocalExerciseTemplatesWithEmptyCollection() throws {
        let services = MockExerciseTemplateServices(exercises: [])
        let manager = ExerciseTemplateManager(services: services)
        
        let exercises = try manager.getAllLocalExerciseTemplates()
        
        #expect(exercises.isEmpty)
    }
    
    @Test("Test Get Local Exercise Templates With Partial Match")
    func testGetLocalExerciseTemplatesWithPartialMatch() throws {
        let mockExercises = ExerciseTemplateModel.mocks
        let services = MockExerciseTemplateServices(exercises: mockExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let idsToRetrieve = [mockExercises[0].id, "non-existent-id", mockExercises[1].id]
        let retrieved = try manager.getLocalExerciseTemplates(ids: idsToRetrieve)
        
        // Should only return the exercises that exist
        #expect(retrieved.count == 2)
    }
    
    @Test("Test Create Multiple Exercise Templates In Sequence")
    func testCreateMultipleExerciseTemplatesInSequence() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        for iteration in 1...5 {
            let exercise = ExerciseTemplateModel(
                exerciseId: "exercise-\(iteration)",
                name: "Exercise \(iteration)",
                dateCreated: Date(),
                dateModified: Date()
            )
            try await manager.createExerciseTemplate(exercise: exercise, image: nil)
        }
        
        // All should succeed without errors
        #expect(true)
    }
    
    @Test("Test Get Exercise Templates With Mixed Exercise Types")
    func testGetExerciseTemplatesWithMixedExerciseTypes() throws {
        let mixedExercises = [
            ExerciseTemplateModel(
                exerciseId: "1",
                name: "Barbell Exercise",
                type: .barbell,
                dateCreated: Date(),
                dateModified: Date()
            ),
            ExerciseTemplateModel(
                exerciseId: "2",
                name: "Dumbbell Exercise",
                type: .dumbbell,
                dateCreated: Date(),
                dateModified: Date()
            ),
            ExerciseTemplateModel(
                exerciseId: "3",
                name: "Bodyweight Exercise",
                type: .weightedBodyweight,
                dateCreated: Date(),
                dateModified: Date()
            ),
            ExerciseTemplateModel(
                exerciseId: "4",
                name: "Cardio Exercise",
                type: .cardio,
                dateCreated: Date(),
                dateModified: Date()
            )
        ]
        
        let services = MockExerciseTemplateServices(exercises: mixedExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let all = try manager.getAllLocalExerciseTemplates()
        
        #expect(all.count == 4)
        let types = Set(all.map { $0.type })
        #expect(types.contains(.barbell))
        #expect(types.contains(.dumbbell))
        #expect(types.contains(.weightedBodyweight))
        #expect(types.contains(.cardio))
    }
    
    @Test("Test Get Exercise Templates With Different Muscle Groups")
    func testGetExerciseTemplatesWithDifferentMuscleGroups() throws {
        let exercises = [
            ExerciseTemplateModel(
                exerciseId: "1",
                name: "Chest Exercise",
                muscleGroups: [.chest],
                dateCreated: Date(),
                dateModified: Date()
            ),
            ExerciseTemplateModel(
                exerciseId: "2",
                name: "Back Exercise",
                muscleGroups: [.back, .arms],
                dateCreated: Date(),
                dateModified: Date()
            ),
            ExerciseTemplateModel(
                exerciseId: "3",
                name: "Full Body",
                muscleGroups: [.chest, .back, .legs, .core],
                dateCreated: Date(),
                dateModified: Date()
            )
        ]
        
        let services = MockExerciseTemplateServices(exercises: exercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let all = try manager.getAllLocalExerciseTemplates()
        
        #expect(all.count == 3)
        #expect(all[0].muscleGroups == [.chest])
        #expect(all[1].muscleGroups == [.back, .arms])
        #expect(all[2].muscleGroups.count == 4)
    }
    
    @Test("Test Add Local Exercise Template With New Exercise Factory Method")
    func testAddLocalExerciseTemplateWithNewExerciseFactoryMethod() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let newExercise = ExerciseTemplateModel.newExerciseTemplate(
            name: "Factory Created Exercise",
            authorId: "author-123",
            description: "Test description",
            instructions: ["Step 1", "Step 2"],
            type: .dumbbell,
            muscleGroups: [.arms]
        )
        
        try await manager.addLocalExerciseTemplate(exercise: newExercise)
        
        // Should succeed without errors
        #expect(true)
    }
}
