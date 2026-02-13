//
//  ExerciseTemplateManagerErrorTests.swift
//  DialedInTests
//

import Testing
import Foundation

struct ExerciseTemplateManagerErrorTests {

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
}
