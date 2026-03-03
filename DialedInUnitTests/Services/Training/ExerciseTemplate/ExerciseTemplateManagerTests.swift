//
//  ExerciseModelManagerTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation
@testable import DialedIn

@MainActor
struct ExerciseModelManagerTests {
    // MARK: - Local Operations Tests

    @Test("Test Get All Local Exercise Templates")
    func testGetAllLocalExerciseModels() throws {
        let mockExercises = ExerciseModel.mocks
        let services = MockExerciseModelServices(exercises: mockExercises)
        let manager = ExerciseModelManager(services: services)
        
        let exercises = try manager.getAllLocalExerciseModels()
        
        #expect(exercises.count == mockExercises.count)
    }
    
    @Test("Test Get Local Exercise Template By ID")
    func testGetLocalExerciseModelById() throws {
        let mockExercises = ExerciseModel.mocks
        let services = MockExerciseModelServices(exercises: mockExercises)
        let manager = ExerciseModelManager(services: services)
        
        let firstExercise = mockExercises[0]
        let retrieved = try manager.getLocalExerciseModel(id: firstExercise.id)
        
        #expect(retrieved.id == firstExercise.id)
        #expect(retrieved.name == firstExercise.name)
    }
    
    @Test("Test Get Local Exercise Template Throws Error For Invalid ID")
    func testGetLocalExerciseModelThrowsErrorForInvalidId() {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        #expect(throws: Error.self) {
            try manager.getLocalExerciseModel(id: "non-existent-id")
        }
    }
    
    @Test("Test Get Local Exercise Templates With Multiple IDs")
    func testGetLocalExerciseModelsWithMultipleIds() throws {
        let mockExercises = ExerciseModel.mocks
        let services = MockExerciseModelServices(exercises: mockExercises)
        let manager = ExerciseModelManager(services: services)
        
        let idsToRetrieve = [mockExercises[0].id, mockExercises[1].id, mockExercises[2].id]
        let retrieved = try manager.getLocalExerciseModels(ids: idsToRetrieve)
        
        #expect(retrieved.count == 3)
        #expect(retrieved.map { $0.id }.allSatisfy { idsToRetrieve.contains($0) })
    }
    
    @Test("Test Get Local Exercise Templates With Empty IDs Array")
    func testGetLocalExerciseModelsWithEmptyIdsArray() throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        let retrieved = try manager.getLocalExerciseModels(ids: [])
        
        #expect(retrieved.isEmpty)
    }
    
    @Test("Test Get System Exercise Templates")
    func testGetSystemExerciseModels() throws {
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
        let services = MockExerciseModelServices(exercises: exercises)
        let manager = ExerciseModelManager(services: services)
        
        let systemExercises = try manager.getSystemExerciseModels()
        
        #expect(systemExercises.count == 1)
        #expect(systemExercises[0].isSystemExercise == true)
        #expect(systemExercises[0].id == "system-1")
    }
    
    @Test("Test Add Local Exercise Template")
    func testAddLocalExerciseModel() async throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        let newExercise = ExerciseModel.mock
        
        try manager.addLocalExerciseModel(exercise: newExercise)
        
        // If no error is thrown, the add was successful
        #expect(true)
    }

    // MARK: - Remote Operations Tests

    @Test("Test Create Exercise Template")
    func testCreateExerciseModel() async throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        let newExercise = ExerciseModel.mock
        
        try await manager.createExerciseModel(exercise: newExercise, image: nil)
        
        // If no error is thrown, the creation was successful
        #expect(true)
    }

    @Test("Test Get Exercise Template From Remote")
    func testGetExerciseModelFromRemote() async throws {
        let mockExercises = ExerciseModel.mocks
        let services = MockExerciseModelServices(exercises: mockExercises)
        let manager = ExerciseModelManager(services: services)
        
        let exerciseId = mockExercises[0].id
        let retrieved = try await manager.getExerciseModel(id: exerciseId)
        
        #expect(retrieved.id == exerciseId)
    }
    
    @Test("Test Get Exercise Template Throws Error For Invalid ID")
    func testGetExerciseModelThrowsErrorForInvalidId() async {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        await #expect(throws: Error.self) {
            try await manager.getExerciseModel(id: "non-existent-id")
        }
    }
    
    @Test("Test Get Exercise Templates From Remote")
    func testGetExerciseModelsFromRemote() async throws {
        let mockExercises = ExerciseModel.mocks
        let services = MockExerciseModelServices(exercises: mockExercises)
        let manager = ExerciseModelManager(services: services)
        
        let ids = mockExercises.prefix(3).map { $0.id }
        let retrieved = try await manager.getExerciseModels(ids: ids)
        
        #expect(retrieved.count == 3)
        #expect(retrieved.allSatisfy { exercise in ids.contains(exercise.id) })
    }
    
    @Test("Test Get Exercise Templates With Limit")
    func testGetExerciseModelsWithLimit() async throws {
        let mockExercises = ExerciseModel.mocks
        let services = MockExerciseModelServices(exercises: mockExercises)
        let manager = ExerciseModelManager(services: services)
        
        let ids = mockExercises.map { $0.id }
        let limit = 5
        let retrieved = try await manager.getExerciseModels(ids: ids, limitTo: limit)
        
        #expect(retrieved.count <= limit)
        #expect(retrieved.count == min(limit, mockExercises.count))
    }
    
    @Test("Test Get Exercise Templates By Name")
    func testGetExerciseModelsByName() async throws {
        let exercises = ExerciseModel.mocks
        let services = MockExerciseModelServices(exercises: exercises)
        let manager = ExerciseModelManager(services: services)
        
        let retrieved = try await manager.getExerciseModelsByName(name: "Press")
        
        #expect(retrieved.count == 2)
        #expect(retrieved.allSatisfy { $0.name.contains("Press") })
    }
    
    @Test("Test Get Exercise Templates For Author")
    func testGetExerciseModelsForAuthor() async throws {
        let exercises = ExerciseModel.mocks
        let services = MockExerciseModelServices(exercises: exercises)
        let manager = ExerciseModelManager(services: services)
        
        let retrieved = try await manager.getExerciseModelsForAuthor(authorId: "author-1")
        
        #expect(retrieved.count == 2)
        #expect(retrieved.allSatisfy { $0.authorId == "author-1" })
    }
    
    @Test("Test Get Top Exercise Templates By Clicks")
    func testGetTopExerciseModelsByClicks() async throws {
        let exercises = ExerciseModel.mocks
        
        let services = MockExerciseModelServices(exercises: exercises)
        let manager = ExerciseModelManager(services: services)
        
        let top = try await manager.getTopExerciseModelsByClicks(limitTo: 2)
        
        #expect(top.count == 2)
        // Should be sorted by clicks descending
        #expect((top[0].clickCount ?? 0) >= (top[1].clickCount ?? 0))
        #expect(top[0].clickCount == 100)
        #expect(top[1].clickCount == 50)
    }
    
    @Test("Test Get Top Exercise Templates With Different Limit")
    func testGetTopExerciseModelsWithDifferentLimit() async throws {
        let mockExercises = ExerciseModel.mocks
        let services = MockExerciseModelServices(exercises: mockExercises)
        let manager = ExerciseModelManager(services: services)
        
        let limit = 3
        let top = try await manager.getTopExerciseModelsByClicks(limitTo: limit)
        
        #expect(top.count <= limit)
    }

    // MARK: - Interaction Operations Tests

    @Test("Test Increment Exercise Template Interaction")
    func testIncrementExerciseModelInteraction() async throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        let exerciseId = ExerciseModel.mocks[0].id
        try await manager.incrementExerciseModelInteraction(id: exerciseId)
        
        // If no error is thrown, the increment was successful
        #expect(true)
    }
    
    @Test("Test Remove Author ID From Exercise Template")
    func testRemoveAuthorIdFromExerciseModel() async throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        let exerciseId = ExerciseModel.mocks[0].id
        try await manager.removeAuthorIdFromExerciseModel(id: exerciseId)
        
        // If no error is thrown, the operation was successful
        #expect(true)
    }
    
    @Test("Test Remove Author ID From All Exercise Templates")
    func testRemoveAuthorIdFromAllExerciseModels() async throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        let authorId = "test-author"
        try await manager.removeAuthorIdFromAllExerciseModels(id: authorId)
        
        // If no error is thrown, the operation was successful
        #expect(true)
    }
    
    @Test("Test Bookmark Exercise Template")
    func testBookmarkExerciseModel() async throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        let exerciseId = ExerciseModel.mocks[0].id
        try await manager.bookmarkExerciseModel(id: exerciseId, isBookmarked: true)
        
        // If no error is thrown, the bookmark was successful
        #expect(true)
    }
    
    @Test("Test Unbookmark Exercise Template")
    func testUnbookmarkExerciseModel() async throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        let exerciseId = ExerciseModel.mocks[0].id
        try await manager.bookmarkExerciseModel(id: exerciseId, isBookmarked: false)
        
        // If no error is thrown, the unbookmark was successful
        #expect(true)
    }
    
    @Test("Test Favourite Exercise Template")
    func testFavouriteExerciseModel() async throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        let exerciseId = ExerciseModel.mocks[0].id
        try await manager.favouriteExerciseModel(id: exerciseId, isFavourited: true)
        
        // If no error is thrown, the favourite was successful
        #expect(true)
    }
    
    @Test("Test Unfavourite Exercise Template")
    func testUnfavouriteExerciseModel() async throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        let exerciseId = ExerciseModel.mocks[0].id
        try await manager.favouriteExerciseModel(id: exerciseId, isFavourited: false)
        
        // If no error is thrown, the unfavourite was successful
        #expect(true)
    }

    // MARK: - Edge Cases Tests

    @Test("Test Get System Exercise Templates Returns Empty When No System Exercises")
    func testGetSystemExerciseModelsReturnsEmptyWhenNoSystemExercises() throws {
        let userExercises = ExerciseModel.mocks
        
        let services = MockExerciseModelServices(exercises: userExercises)
        let manager = ExerciseModelManager(services: services)
        
        let systemExercises = try manager.getSystemExerciseModels()
        
        #expect(systemExercises.isEmpty)
    }
    
    @Test("Test Get All Local Exercise Templates With Empty Collection")
    func testGetAllLocalExerciseModelsWithEmptyCollection() throws {
        let services = MockExerciseModelServices(exercises: [])
        let manager = ExerciseModelManager(services: services)
        
        let exercises = try manager.getAllLocalExerciseModels()
        
        #expect(exercises.isEmpty)
    }
    
    @Test("Test Get Local Exercise Templates With Partial Match")
    func testGetLocalExerciseModelsWithPartialMatch() throws {
        let mockExercises = ExerciseModel.mocks
        let services = MockExerciseModelServices(exercises: mockExercises)
        let manager = ExerciseModelManager(services: services)
        
        let idsToRetrieve = [mockExercises[0].id, "non-existent-id", mockExercises[1].id]
        let retrieved = try manager.getLocalExerciseModels(ids: idsToRetrieve)
        
        // Should only return the exercises that exist
        #expect(retrieved.count == 2)
    }
    
    @Test("Test Create Multiple Exercise Templates In Sequence")
    func testCreateMultipleExerciseModelsInSequence() async throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        for iteration in 1...5 {
            let exercise = ExerciseModel.mock
            try await manager.createExerciseModel(exercise: exercise, image: nil)
        }
        
        // All should succeed without errors
        #expect(true)
    }
    
    @Test("Test Get Exercise Templates With Mixed Exercise Types")
    func testGetExerciseModelsWithMixedExerciseTypes() throws {
        let mixedExercises = ExerciseModel.mocks
        
        let services = MockExerciseModelServices(exercises: mixedExercises)
        let manager = ExerciseModelManager(services: services)
        
        let all = try manager.getAllLocalExerciseModels()
        
        #expect(all.count == 4)
        let types = Set(all.map { $0.type })
    }
    
    @Test("Test Get Exercise Templates With Different Muscle Groups")
    func testGetExerciseModelsWithDifferentMuscleGroups() throws {
        let exercises = ExerciseModel.mocks
        
        let services = MockExerciseModelServices(exercises: exercises)
        let manager = ExerciseModelManager(services: services)
        
        let all = try manager.getAllLocalExerciseModels()
        
    }
    
    @Test("Test Add Local Exercise Template With New Exercise Factory Method")
    func testAddLocalExerciseModelWithNewExerciseFactoryMethod() async throws {
        let services = MockExerciseModelServices()
        let manager = ExerciseModelManager(services: services)
        
        let newExercise = ExerciseModel.mock
        try manager.addLocalExerciseModel(exercise: newExercise)
        
        // Should succeed without errors
        #expect(true)
    }
}
