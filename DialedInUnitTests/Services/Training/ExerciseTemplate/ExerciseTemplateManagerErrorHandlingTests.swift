//
//  ExerciseModelManagerErrorTests.swift
//  DialedInUnitTests
//

import Testing
import Foundation
@testable import DialedIn

@MainActor
struct ExerciseModelManagerErrorTests {

    @Test("Test Get All Local Exercise Templates Throws Error When Service Fails")
    func testGetAllLocalExerciseModelsThrowsErrorWhenServiceFails() {
        let services = MockExerciseModelServices(showError: true)
        let manager = ExerciseModelManager(services: services)

        #expect(throws: URLError.self) {
            try manager.getAllLocalExerciseModels()
        }
    }

    @Test("Test Get Local Exercise Template Throws Error When Service Fails")
    func testGetLocalExerciseModelThrowsErrorWhenServiceFails() {
        let services = MockExerciseModelServices(showError: true)
        let manager = ExerciseModelManager(services: services)

        #expect(throws: URLError.self) {
            try manager.getLocalExerciseModel(id: "test-id")
        }
    }

    @Test("Test Create Exercise Template Throws Error When Service Fails")
    func testCreateExerciseModelThrowsErrorWhenServiceFails() async {
        let services = MockExerciseModelServices(showError: true)
        let manager = ExerciseModelManager(services: services)

        let exercise = ExerciseModel(
            authorId: "test_user",
            name: "Test Exercise",
            trackableMetrics: [.weight, .reps],
            type: .compoundUpper,
            laterality: .bilateral,
            muscleGroups: [:],
            isBodyweight: false,
            resistanceEquipment: [],
            supportEquipment: [],
            rangeOfMotion: 4,
            stability: 5,
            bodyWeightContribution: 75,
            alternateNames: []
        )

        await #expect(throws: URLError.self) {
            try await manager.createExerciseModel(exercise: exercise, image: nil)
        }
    }

    @Test("Test Get Exercise Template Throws Error When Service Fails")
    func testGetExerciseModelThrowsErrorWhenServiceFails() async {
        let services = MockExerciseModelServices(showError: true)
        let manager = ExerciseModelManager(services: services)

        await #expect(throws: URLError.self) {
            try await manager.getExerciseModel(id: "test-id")
        }
    }

    @Test("Test Get Exercise Templates By Name Throws Error When Service Fails")
    func testGetExerciseModelsByNameThrowsErrorWhenServiceFails() async {
        let services = MockExerciseModelServices(showError: true)
        let manager = ExerciseModelManager(services: services)

        await #expect(throws: URLError.self) {
            try await manager.getExerciseModelsByName(name: "Test")
        }
    }

    @Test("Test Increment Interaction Throws Error When Service Fails")
    func testIncrementInteractionThrowsErrorWhenServiceFails() async {
        let services = MockExerciseModelServices(showError: true)
        let manager = ExerciseModelManager(services: services)

        await #expect(throws: URLError.self) {
            try await manager.incrementExerciseModelInteraction(id: "test-id")
        }
    }

    @Test("Test Bookmark Exercise Template Throws Error When Service Fails")
    func testBookmarkExerciseModelThrowsErrorWhenServiceFails() async {
        let services = MockExerciseModelServices(showError: true)
        let manager = ExerciseModelManager(services: services)

        await #expect(throws: URLError.self) {
            try await manager.bookmarkExerciseModel(id: "test-id", isBookmarked: true)
        }
    }

    @Test("Test Favourite Exercise Template Throws Error When Service Fails")
    func testFavouriteExerciseModelThrowsErrorWhenServiceFails() async {
        let services = MockExerciseModelServices(showError: true)
        let manager = ExerciseModelManager(services: services)

        await #expect(throws: URLError.self) {
            try await manager.favouriteExerciseModel(id: "test-id", isFavourited: true)
        }
    }
}
