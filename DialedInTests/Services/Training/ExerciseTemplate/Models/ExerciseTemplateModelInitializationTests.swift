//
//  ExerciseTemplateModelInitializationTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation

struct ExerciseTemplateInitTests {

    // MARK: - Initialization Tests
    
    @Test("Test Basic Initialization")
    func testBasicInitialization() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.exerciseId == randomExerciseId)
        #expect(exercise.name == randomName)
        #expect(exercise.dateCreated == randomDate)
        #expect(exercise.dateModified == randomDate)
        #expect(exercise.authorId == nil)
        #expect(exercise.description == nil)
        #expect(exercise.instructions.isEmpty)
        #expect(exercise.type == .none)
        #expect(exercise.muscleGroups.isEmpty)
        #expect(exercise.imageURL == nil)
        #expect(exercise.isSystemExercise == false)
        #expect(exercise.clickCount == nil)
        #expect(exercise.bookmarkCount == nil)
        #expect(exercise.favouriteCount == nil)
    }
    
    @Test("Test Initialization With All Properties")
    func testInitializationWithAllProperties() {
        let randomExerciseId = String.random
        let randomAuthorId = String.random
        let randomName = String.random
        let randomDescription = String.random
        let randomInstructions = ["Step 1", "Step 2", "Step 3"]
        let randomImageUrl = "https://example.com/image.jpg"
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
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
        
        #expect(exercise.exerciseId == randomExerciseId)
        #expect(exercise.authorId == randomAuthorId)
        #expect(exercise.name == randomName)
        #expect(exercise.description == randomDescription)
        #expect(exercise.instructions == randomInstructions)
        #expect(exercise.type == .barbell)
        #expect(exercise.muscleGroups == [.chest, .arms])
        #expect(exercise.imageURL == randomImageUrl)
        #expect(exercise.isSystemExercise == true)
        #expect(exercise.clickCount == 10)
        #expect(exercise.bookmarkCount == 5)
        #expect(exercise.favouriteCount == 2)
    }
    
    @Test("Test Initialization With Nil Optional Values")
    func testInitializationWithNilOptionalValues() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
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
        
        #expect(exercise.authorId == nil)
        #expect(exercise.description == nil)
        #expect(exercise.instructions.isEmpty)
        #expect(exercise.muscleGroups.isEmpty)
        #expect(exercise.imageURL == nil)
        #expect(exercise.clickCount == nil)
        #expect(exercise.bookmarkCount == nil)
        #expect(exercise.favouriteCount == nil)
    }
    
    @Test("Test Initialization With Different Exercise Types")
    func testInitializationWithDifferentExerciseTypes() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let barbellExercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            type: .barbell,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        let dumbbellExercise = ExerciseTemplateModel(
            exerciseId: String.random,
            name: randomName,
            type: .dumbbell,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        let bodyweightExercise = ExerciseTemplateModel(
            exerciseId: String.random,
            name: randomName,
            type: .weightedBodyweight,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(barbellExercise.type == .barbell)
        #expect(dumbbellExercise.type == .dumbbell)
        #expect(bodyweightExercise.type == .weightedBodyweight)
    }
    
    @Test("Test Initialization With Different Muscle Groups")
    func testInitializationWithDifferentMuscleGroups() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let chestExercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            muscleGroups: [.chest],
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        let compoundExercise = ExerciseTemplateModel(
            exerciseId: String.random,
            name: randomName,
            muscleGroups: [.legs, .back, .core],
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(chestExercise.muscleGroups == [.chest])
        #expect(compoundExercise.muscleGroups == [.legs, .back, .core])
    }
    
    @Test("Test Initialization With Empty Instructions")
    func testInitializationWithEmptyInstructions() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            instructions: [],
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.instructions.isEmpty)
        #expect(exercise.instructions.count == 0)
    }
    
    @Test("Test Initialization With Multiple Instructions")
    func testInitializationWithMultipleInstructions() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        let instructions = [
            "Step 1: Setup",
            "Step 2: Execute",
            "Step 3: Return to starting position"
        ]
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            instructions: instructions,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.instructions.count == 3)
        #expect(exercise.instructions[0] == "Step 1: Setup")
        #expect(exercise.instructions[1] == "Step 2: Execute")
        #expect(exercise.instructions[2] == "Step 3: Return to starting position")
    }
    
    @Test("Test New Exercise Template Factory Method")
    func testNewExerciseTemplateFactoryMethod() {
        let randomName = String.random
        let randomAuthorId = String.random
        let randomDescription = String.random
        let instructions = ["Step 1", "Step 2"]
        
        let exercise = ExerciseTemplateModel.newExerciseTemplate(
            name: randomName,
            authorId: randomAuthorId,
            description: randomDescription,
            instructions: instructions,
            type: .dumbbell,
            muscleGroups: [.chest, .shoulders]
        )
        
        #expect(exercise.name == randomName)
        #expect(exercise.authorId == randomAuthorId)
        #expect(exercise.description == randomDescription)
        #expect(exercise.instructions == instructions)
        #expect(exercise.type == .dumbbell)
        #expect(exercise.muscleGroups == [.chest, .shoulders])
        #expect(exercise.clickCount == 0)
        #expect(exercise.bookmarkCount == 0)
        #expect(exercise.favouriteCount == 0)
        #expect(!exercise.exerciseId.isEmpty)
    }
    
    @Test("Test System Exercise Flag")
    func testSystemExerciseFlag() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let systemExercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            isSystemExercise: true,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        let userExercise = ExerciseTemplateModel(
            exerciseId: String.random,
            name: randomName,
            isSystemExercise: false,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(systemExercise.isSystemExercise == true)
        #expect(userExercise.isSystemExercise == false)
    }
}
