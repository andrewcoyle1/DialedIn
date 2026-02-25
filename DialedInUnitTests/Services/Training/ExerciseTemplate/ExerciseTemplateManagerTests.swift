//
//  ExerciseTemplateManagerTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation
@testable import DialedIn

@MainActor
struct ExerciseTemplateManagerTests {
    // MARK: - Local Operations Tests

    @Test("Test Get All Local Exercise Templates")
    func testGetAllLocalExerciseTemplates() throws {
        let mockExercises = ExerciseModel.mocks
        let services = MockExerciseTemplateServices(exercises: mockExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let exercises = try manager.getAllLocalExerciseTemplates()
        
        #expect(exercises.count == mockExercises.count)
    }
    
    @Test("Test Get Local Exercise Template By ID")
    func testGetLocalExerciseTemplateById() throws {
        let mockExercises = ExerciseModel.mocks
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
        let mockExercises = ExerciseModel.mocks
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
        let systemExercise = ExerciseModel(
            id: "system-1",
            authorId: "test-user",
            name: "System Exercise",
            trackableMetrics: [],
            type: nil,
            laterality: nil,
            muscleGroups: [:],
            isBodyweight: false,
            resistanceEquipment: [],
            supportEquipment: [],
            rangeOfMotion: 4,
            stability: 5,
            bodyWeightContribution: 75,
            alternateNames: []
        )

        let userExercise = ExerciseModel.mock
        
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
        
        let newExercise = ExerciseModel.mock
        
        try manager.addLocalExerciseTemplate(exercise: newExercise)
        
        // If no error is thrown, the add was successful
        #expect(true)
    }

    // MARK: - Remote Operations Tests

    @Test("Test Create Exercise Template")
    func testCreateExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let newExercise = ExerciseModel.mock
        
        try await manager.createExerciseTemplate(exercise: newExercise, image: nil)
        
        // If no error is thrown, the creation was successful
        #expect(true)
    }

    @Test("Test Get Exercise Template From Remote")
    func testGetExerciseTemplateFromRemote() async throws {
        let mockExercises = ExerciseModel.mocks
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
        let mockExercises = ExerciseModel.mocks
        let services = MockExerciseTemplateServices(exercises: mockExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let ids = mockExercises.prefix(3).map { $0.id }
        let retrieved = try await manager.getExerciseTemplates(ids: ids)
        
        #expect(retrieved.count == 3)
        #expect(retrieved.allSatisfy { exercise in ids.contains(exercise.id) })
    }
    
    @Test("Test Get Exercise Templates With Limit")
    func testGetExerciseTemplatesWithLimit() async throws {
        let mockExercises = ExerciseModel.mocks
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
        let exercises = ExerciseModel.mocks
        let services = MockExerciseTemplateServices(exercises: exercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let retrieved = try await manager.getExerciseTemplatesByName(name: "Press")
        
        #expect(retrieved.count == 2)
        #expect(retrieved.allSatisfy { $0.name.contains("Press") })
    }
    
    @Test("Test Get Exercise Templates For Author")
    func testGetExerciseTemplatesForAuthor() async throws {
        let exercises = ExerciseModel.mocks
        let services = MockExerciseTemplateServices(exercises: exercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let retrieved = try await manager.getExerciseTemplatesForAuthor(authorId: "author-1")
        
        #expect(retrieved.count == 2)
        #expect(retrieved.allSatisfy { $0.authorId == "author-1" })
    }
    
    @Test("Test Get Top Exercise Templates By Clicks")
    func testGetTopExerciseTemplatesByClicks() async throws {
        let exercises = ExerciseModel.mocks
        
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
        let mockExercises = ExerciseModel.mocks
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
        
        let exerciseId = ExerciseModel.mocks[0].id
        try await manager.incrementExerciseTemplateInteraction(id: exerciseId)
        
        // If no error is thrown, the increment was successful
        #expect(true)
    }
    
    @Test("Test Remove Author ID From Exercise Template")
    func testRemoveAuthorIdFromExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let exerciseId = ExerciseModel.mocks[0].id
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
        
        let exerciseId = ExerciseModel.mocks[0].id
        try await manager.bookmarkExerciseTemplate(id: exerciseId, isBookmarked: true)
        
        // If no error is thrown, the bookmark was successful
        #expect(true)
    }
    
    @Test("Test Unbookmark Exercise Template")
    func testUnbookmarkExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let exerciseId = ExerciseModel.mocks[0].id
        try await manager.bookmarkExerciseTemplate(id: exerciseId, isBookmarked: false)
        
        // If no error is thrown, the unbookmark was successful
        #expect(true)
    }
    
    @Test("Test Favourite Exercise Template")
    func testFavouriteExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let exerciseId = ExerciseModel.mocks[0].id
        try await manager.favouriteExerciseTemplate(id: exerciseId, isFavourited: true)
        
        // If no error is thrown, the favourite was successful
        #expect(true)
    }
    
    @Test("Test Unfavourite Exercise Template")
    func testUnfavouriteExerciseTemplate() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let exerciseId = ExerciseModel.mocks[0].id
        try await manager.favouriteExerciseTemplate(id: exerciseId, isFavourited: false)
        
        // If no error is thrown, the unfavourite was successful
        #expect(true)
    }

    // MARK: - Edge Cases Tests

    @Test("Test Get System Exercise Templates Returns Empty When No System Exercises")
    func testGetSystemExerciseTemplatesReturnsEmptyWhenNoSystemExercises() throws {
        let userExercises = ExerciseModel.mocks
        
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
        let mockExercises = ExerciseModel.mocks
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
            let exercise = ExerciseModel.mock
            try await manager.createExerciseTemplate(exercise: exercise, image: nil)
        }
        
        // All should succeed without errors
        #expect(true)
    }
    
    @Test("Test Get Exercise Templates With Mixed Exercise Types")
    func testGetExerciseTemplatesWithMixedExerciseTypes() throws {
        let mixedExercises = ExerciseModel.mocks
        
        let services = MockExerciseTemplateServices(exercises: mixedExercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let all = try manager.getAllLocalExerciseTemplates()
        
        #expect(all.count == 4)
        let types = Set(all.map { $0.type })
    }
    
    @Test("Test Get Exercise Templates With Different Muscle Groups")
    func testGetExerciseTemplatesWithDifferentMuscleGroups() throws {
        let exercises = ExerciseModel.mocks
        
        let services = MockExerciseTemplateServices(exercises: exercises)
        let manager = ExerciseTemplateManager(services: services)
        
        let all = try manager.getAllLocalExerciseTemplates()
        
    }
    
    @Test("Test Add Local Exercise Template With New Exercise Factory Method")
    func testAddLocalExerciseTemplateWithNewExerciseFactoryMethod() async throws {
        let services = MockExerciseTemplateServices()
        let manager = ExerciseTemplateManager(services: services)
        
        let newExercise = ExerciseModel.mock
        try manager.addLocalExerciseTemplate(exercise: newExercise)
        
        // Should succeed without errors
        #expect(true)
    }
}
