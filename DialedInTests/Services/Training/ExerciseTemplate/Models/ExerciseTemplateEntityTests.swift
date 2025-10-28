//
//  ExerciseTemplateEntityTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation

struct ExerciseTemplateEntityTests {

    // MARK: - Entity Initialization Tests
    
    @Test("Test Entity Initialization From Model")
    func testEntityInitializationFromModel() {
        let randomExerciseId = String.random
        let randomAuthorId = String.random
        let randomName = String.random
        let randomDescription = String.random
        let randomInstructions = ["Step 1", "Step 2", "Step 3"]
        let randomImageUrl = "https://example.com/image.jpg"
        let randomDate = Date.random
        
        let model = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            authorId: randomAuthorId,
            name: randomName,
            description: randomDescription,
            instructions: randomInstructions,
            type: .barbell,
            muscleGroups: [.chest, .arms],
            imageURL: randomImageUrl,
            isSystemExercise: true,
            dateCreated: randomDate,
            dateModified: randomDate,
            clickCount: 10,
            bookmarkCount: 5,
            favouriteCount: 2
        )
        
        let entity = ExerciseTemplateEntity(from: model)
        
        #expect(entity.exerciseTemplateId == randomExerciseId)
        #expect(entity.authorId == randomAuthorId)
        #expect(entity.name == randomName)
        #expect(entity.exerciseDescription == randomDescription)
        #expect(entity.instructions == randomInstructions)
        #expect(entity.type == .barbell)
        #expect(entity.muscleGroups == [.chest, .arms])
        #expect(entity.imageURL == randomImageUrl)
        #expect(entity.isSystemExercise == true)
        #expect(entity.dateCreated == randomDate)
        #expect(entity.dateModified == randomDate)
        #expect(entity.clickCount == 10)
        #expect(entity.bookmarkCount == 5)
        #expect(entity.favouriteCount == 2)
    }
    
    @Test("Test Entity Initialization With Nil Values")
    func testEntityInitializationWithNilValues() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let model = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            authorId: nil,
            name: randomName,
            description: nil,
            instructions: [],
            type: .none,
            muscleGroups: [],
            imageURL: nil,
            isSystemExercise: false,
            dateCreated: randomDate,
            dateModified: randomDate,
            clickCount: nil,
            bookmarkCount: nil,
            favouriteCount: nil
        )
        
        let entity = ExerciseTemplateEntity(from: model)
        
        #expect(entity.authorId == nil)
        #expect(entity.exerciseDescription == nil)
        #expect(entity.instructions.isEmpty)
        #expect(entity.muscleGroups.isEmpty)
        #expect(entity.imageURL == nil)
        #expect(entity.clickCount == nil)
        #expect(entity.bookmarkCount == nil)
        #expect(entity.favouriteCount == nil)
    }
    
    // MARK: - Entity To Model Conversion Tests
    
    @Test("Test Entity To Model Conversion")
    func testEntityToModelConversion() async {
        let randomExerciseId = String.random
        let randomAuthorId = String.random
        let randomName = String.random
        let randomDescription = String.random
        let randomInstructions = ["Step 1", "Step 2", "Step 3"]
        let randomImageUrl = "https://example.com/image.jpg"
        let randomDate = Date.random
        
        let originalModel = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            authorId: randomAuthorId,
            name: randomName,
            description: randomDescription,
            instructions: randomInstructions,
            type: .dumbbell,
            muscleGroups: [.shoulders, .core],
            imageURL: randomImageUrl,
            isSystemExercise: false,
            dateCreated: randomDate,
            dateModified: randomDate,
            clickCount: 15,
            bookmarkCount: 7,
            favouriteCount: 3
        )
        
        let entity = ExerciseTemplateEntity(from: originalModel)
        let convertedModel = entity.toModel()
        
        #expect(convertedModel.exerciseId == randomExerciseId)
        #expect(convertedModel.authorId == randomAuthorId)
        #expect(convertedModel.name == randomName)
        #expect(convertedModel.description == randomDescription)
        #expect(convertedModel.instructions == randomInstructions)
        #expect(convertedModel.type == .dumbbell)
        #expect(convertedModel.muscleGroups == [.shoulders, .core])
        #expect(convertedModel.imageURL == randomImageUrl)
        #expect(convertedModel.isSystemExercise == false)
        #expect(convertedModel.dateCreated == randomDate)
        #expect(convertedModel.dateModified == randomDate)
        #expect(convertedModel.clickCount == 15)
        #expect(convertedModel.bookmarkCount == 7)
        #expect(convertedModel.favouriteCount == 3)
    }
    
    @Test("Test Round Trip Conversion")
    func testRoundTripConversion() async {
        let randomExerciseId = String.random
        let randomAuthorId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let originalModel = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            authorId: randomAuthorId,
            name: randomName,
            description: "Original description",
            instructions: ["Step 1", "Step 2"],
            type: .cable,
            muscleGroups: [.back, .arms],
            imageURL: "https://example.com/original.jpg",
            isSystemExercise: true,
            dateCreated: randomDate,
            dateModified: randomDate,
            clickCount: 20,
            bookmarkCount: 10,
            favouriteCount: 5
        )
        
        // Convert to entity and back to model
        let entity = ExerciseTemplateEntity(from: originalModel)
        let convertedModel = entity.toModel()
        
        // Should be identical
        #expect(convertedModel.exerciseId == originalModel.exerciseId)
        #expect(convertedModel.authorId == originalModel.authorId)
        #expect(convertedModel.name == originalModel.name)
        #expect(convertedModel.description == originalModel.description)
        #expect(convertedModel.instructions == originalModel.instructions)
        #expect(convertedModel.type == originalModel.type)
        #expect(convertedModel.muscleGroups == originalModel.muscleGroups)
        #expect(convertedModel.imageURL == originalModel.imageURL)
        #expect(convertedModel.isSystemExercise == originalModel.isSystemExercise)
        #expect(convertedModel.dateCreated == originalModel.dateCreated)
        #expect(convertedModel.dateModified == originalModel.dateModified)
        #expect(convertedModel.clickCount == originalModel.clickCount)
        #expect(convertedModel.bookmarkCount == originalModel.bookmarkCount)
        #expect(convertedModel.favouriteCount == originalModel.favouriteCount)
    }
    
    @Test("Test Round Trip With Nil Values")
    func testRoundTripWithNilValues() async {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let originalModel = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            authorId: nil,
            name: randomName,
            description: nil,
            instructions: [],
            type: .none,
            muscleGroups: [],
            imageURL: nil,
            isSystemExercise: false,
            dateCreated: randomDate,
            dateModified: randomDate,
            clickCount: nil,
            bookmarkCount: nil,
            favouriteCount: nil
        )
        
        let entity = ExerciseTemplateEntity(from: originalModel)
        let convertedModel = entity.toModel()
        
        #expect(convertedModel.exerciseId == originalModel.exerciseId)
        #expect(convertedModel.authorId == originalModel.authorId)
        #expect(convertedModel.name == originalModel.name)
        #expect(convertedModel.description == originalModel.description)
        #expect(convertedModel.instructions == originalModel.instructions)
        #expect(convertedModel.type == originalModel.type)
        #expect(convertedModel.muscleGroups == originalModel.muscleGroups)
        #expect(convertedModel.imageURL == originalModel.imageURL)
        #expect(convertedModel.clickCount == originalModel.clickCount)
        #expect(convertedModel.bookmarkCount == originalModel.bookmarkCount)
        #expect(convertedModel.favouriteCount == originalModel.favouriteCount)
    }
    
    @Test("Test Entity With Different Exercise Types")
    func testEntityWithDifferentExerciseTypes() async {
        let exerciseTypes: [ExerciseCategory] = [.barbell, .dumbbell, .kettlebell, .machine, .cable, .weightedBodyweight, .cardio]
        
        for exerciseType in exerciseTypes {
            let model = ExerciseTemplateModel(
                exerciseId: String.random,
                name: "Test Exercise",
                type: exerciseType,
                dateCreated: Date.random,
                dateModified: Date.random
            )
            
            let entity = ExerciseTemplateEntity(from: model)
            let convertedModel = entity.toModel()
            
            #expect(entity.type == exerciseType)
            #expect(convertedModel.type == exerciseType)
        }
    }
    
    @Test("Test Entity With Different Muscle Groups")
    func testEntityWithDifferentMuscleGroups() async {
        let muscleGroupCombinations: [[MuscleGroup]] = [
            [.chest],
            [.back, .arms],
            [.legs, .core],
            [.shoulders, .chest, .arms],
            [.chest, .shoulders, .back, .arms, .legs, .core]
        ]
        
        for muscleGroups in muscleGroupCombinations {
            let model = ExerciseTemplateModel(
                exerciseId: String.random,
                name: "Test Exercise",
                muscleGroups: muscleGroups,
                dateCreated: Date.random,
                dateModified: Date.random
            )
            
            let entity = ExerciseTemplateEntity(from: model)
            let convertedModel = entity.toModel()
            
            #expect(entity.muscleGroups == muscleGroups)
            #expect(convertedModel.muscleGroups == muscleGroups)
        }
    }
    
    @Test("Test Entity Preserves Complex Instructions")
    func testEntityPreservesComplexInstructions() async {
        let complexInstructions = [
            "Step 1: Setup with feet shoulder-width apart",
            "Step 2: Lower yourself slowly for 3 seconds",
            "Step 3: Pause at the bottom for 1 second",
            "Step 4: Explode up to starting position",
            "Step 5: Repeat for desired repetitions"
        ]
        
        let model = ExerciseTemplateModel(
            exerciseId: String.random,
            name: "Complex Exercise",
            instructions: complexInstructions,
            dateCreated: Date.random,
            dateModified: Date.random
        )
        
        let entity = ExerciseTemplateEntity(from: model)
        let convertedModel = entity.toModel()
        
        #expect(entity.instructions == complexInstructions)
        #expect(convertedModel.instructions == complexInstructions)
    }
    
    @Test("Test Entity With Mock Data")
    func testEntityWithMockData() async {
        let mock = ExerciseTemplateModel.mock
        
        let entity = ExerciseTemplateEntity(from: mock)
        let convertedModel = entity.toModel()
        
        #expect(entity.name == "Bench Press")
        #expect(entity.type == .barbell)
        #expect(convertedModel.name == mock.name)
        #expect(convertedModel.exerciseId == mock.exerciseId)
    }
    
    @Test("Test Multiple Entities From Mocks")
    func testMultipleEntitiesFromMocks() async {
        let mocks = ExerciseTemplateModel.mocks
        
        for mock in mocks {
            let entity = ExerciseTemplateEntity(from: mock)
            let convertedModel = entity.toModel()
            
            #expect(convertedModel.exerciseId == mock.exerciseId)
            #expect(convertedModel.name == mock.name)
            #expect(convertedModel.type == mock.type)
        }
    }
}
