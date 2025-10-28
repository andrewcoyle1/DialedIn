//
//  ExerciseTemplateModelMockAndEdgeCasesTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation

struct ExerciseTemplateMockTests {

    // MARK: - Mock Tests
    
    @Test("Test Mock Property")
    func testMockProperty() {
        let mock = ExerciseTemplateModel.mock
        
        #expect(mock.exerciseId == "1")
        #expect(mock.authorId == "1")
        #expect(mock.name == "Bench Press")
        #expect(mock.description == "Press a barbell up to shoulder height.")
        #expect(mock.type == .barbell)
        #expect(mock.muscleGroups == [.chest, .arms])
        #expect(mock.clickCount == 48)
        #expect(mock.bookmarkCount == 3)
        #expect(mock.favouriteCount == 2)
    }
    
    @Test("Test Mocks Property")
    func testMocksProperty() {
        let mocks = ExerciseTemplateModel.mocks
        
        #expect(mocks.count == 10)
        #expect(mocks[0].name == "Bench Press")
        #expect(mocks[1].name == "Squat")
        #expect(mocks[2].name == "Deadlift")
        #expect(mocks[3].name == "Pull-Up")
        #expect(mocks[4].name == "Push-Up")
    }
    
    @Test("Test Mocks Have Different Exercise Types")
    func testMocksHaveDifferentExerciseTypes() {
        let mocks = ExerciseTemplateModel.mocks
        
        #expect(mocks[0].type == .barbell) // Bench Press
        #expect(mocks[1].type == .barbell) // Squat
        #expect(mocks[3].type == .weightedBodyweight) // Pull-Up
        #expect(mocks[5].type == .dumbbell) // Dumbbell Curl
        #expect(mocks[6].type == .cable) // Tricep Rope Pushdown
        #expect(mocks[7].type == .machine) // Leg Press
        #expect(mocks[9].type == .cardio) // Treadmill Run
    }
    
    @Test("Test Mocks Have Different Muscle Groups")
    func testMocksHaveDifferentMuscleGroups() {
        let mocks = ExerciseTemplateModel.mocks
        
        #expect(mocks[0].muscleGroups == [.chest, .arms]) // Bench Press
        #expect(mocks[1].muscleGroups == [.legs, .core]) // Squat
        #expect(mocks[2].muscleGroups == [.back, .legs, .core]) // Deadlift
        #expect(mocks[3].muscleGroups == [.back, .arms]) // Pull-Up
        #expect(mocks[8].muscleGroups == [.core]) // Plank
    }
    
    @Test("Test Mocks Have Different Author IDs")
    func testMocksHaveDifferentAuthorIds() {
        let mocks = ExerciseTemplateModel.mocks
        
        #expect(mocks[0].authorId == "1")
        #expect(mocks[1].authorId == "2")
        #expect(mocks[2].authorId == "3")
        #expect(mocks[3].authorId == "4")
    }
    
    @Test("Test Mocks Have Instructions")
    func testMocksHaveInstructions() {
        let mocks = ExerciseTemplateModel.mocks
        
        for mock in mocks {
            #expect(!mock.instructions.isEmpty)
        }
    }
    
    @Test("Test Mocks Have Different Click Counts")
    func testMocksHaveDifferentClickCounts() {
        let mocks = ExerciseTemplateModel.mocks
        
        #expect(mocks[0].clickCount == 48)
        #expect(mocks[1].clickCount == 34)
        #expect(mocks[2].clickCount == 23)
        #expect(mocks[9].clickCount == 0)
    }
    
    // MARK: - Event Parameters Tests
    
    @Test("Test Event Parameters")
    func testEventParameters() {
        let randomExerciseId = String.random
        let randomAuthorId = String.random
        let randomName = String.random
        let randomDescription = String.random
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            authorId: randomAuthorId,
            name: randomName,
            description: randomDescription,
            instructions: ["Step 1", "Step 2"],
            type: .barbell,
            muscleGroups: [.chest, .arms],
            imageURL: "https://example.com/image.jpg",
            dateCreated: randomDate,
            dateModified: randomDate,
            clickCount: 10,
            bookmarkCount: 5,
            favouriteCount: 2
        )
        
        let eventParams = exercise.eventParameters
        
        #expect(eventParams["user_exercise_id"] as? String == randomExerciseId)
        #expect(eventParams["user_author_id"] as? String == randomAuthorId)
        #expect(eventParams["user_name"] as? String == randomName)
        #expect(eventParams["user_description"] as? String == randomDescription)
        #expect(eventParams["user_type"] != nil)
        #expect(eventParams["user_muscle_groups"] != nil)
        #expect(eventParams["user_click_count"] as? Int == 10)
        #expect(eventParams["user_bookmark_count"] as? Int == 5)
        #expect(eventParams["user_favourite_count"] as? Int == 2)
    }
    
    @Test("Test Event Parameters Filters Nil Values")
    func testEventParametersFiltersNilValues() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            authorId: nil,
            name: randomName,
            description: nil,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        let eventParams = exercise.eventParameters
        
        #expect(eventParams["user_exercise_id"] as? String == randomExerciseId)
        #expect(eventParams["user_author_id"] == nil)
        #expect(eventParams["user_description"] == nil)
        #expect(eventParams["user_image_url"] == nil)
    }
    
    @Test("Test Event Parameters Includes Arrays")
    func testEventParametersIncludesArrays() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        let instructions = ["Step 1", "Step 2", "Step 3"]
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            instructions: instructions,
            muscleGroups: [.chest, .arms, .core],
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        let eventParams = exercise.eventParameters
        
        #expect(eventParams["user_instructions"] != nil)
        #expect(eventParams["user_muscle_groups"] != nil)
    }
    
    // MARK: - Edge Cases
    
    @Test("Test Empty Name")
    func testEmptyName() {
        let randomExerciseId = String.random
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: "",
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.name.isEmpty)
    }
    
    @Test("Test Very Long Name")
    func testVeryLongName() {
        let randomExerciseId = String.random
        let longName = String(repeating: "a", count: 1000)
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: longName,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.name.count == 1000)
    }
    
    @Test("Test Very Long Description")
    func testVeryLongDescription() {
        let randomExerciseId = String.random
        let randomName = String.random
        let longDescription = String(repeating: "b", count: 5000)
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            description: longDescription,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.description?.count == 5000)
    }
    
    @Test("Test Many Instructions")
    func testManyInstructions() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        let manyInstructions = (1...100).map { "Step \($0)" }
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            instructions: manyInstructions,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.instructions.count == 100)
    }
    
    @Test("Test All Muscle Groups")
    func testAllMuscleGroups() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        let allMuscleGroups: [MuscleGroup] = [.chest, .shoulders, .back, .arms, .legs, .core]
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            muscleGroups: allMuscleGroups,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.muscleGroups.count == 6)
    }
    
    @Test("Test Zero Interaction Counts")
    func testZeroInteractionCounts() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            dateCreated: randomDate,
            dateModified: randomDate,
            clickCount: 0,
            bookmarkCount: 0,
            favouriteCount: 0
        )
        
        #expect(exercise.clickCount == 0)
        #expect(exercise.bookmarkCount == 0)
        #expect(exercise.favouriteCount == 0)
    }
    
    @Test("Test Very High Interaction Counts")
    func testVeryHighInteractionCounts() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            dateCreated: randomDate,
            dateModified: randomDate,
            clickCount: 999999,
            bookmarkCount: 888888,
            favouriteCount: 777777
        )
        
        #expect(exercise.clickCount == 999999)
        #expect(exercise.bookmarkCount == 888888)
        #expect(exercise.favouriteCount == 777777)
    }
    
    @Test("Test Special Characters In Name")
    func testSpecialCharactersInName() {
        let randomExerciseId = String.random
        let specialName = "Test-Exercise_123!@#$%^&*()"
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: specialName,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.name == specialName)
    }
    
    @Test("Test Unicode Characters In Name")
    func testUnicodeCharactersInName() {
        let randomExerciseId = String.random
        let unicodeName = "Упражнение 运动 エクササイズ 🏋️"
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: unicodeName,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.name == unicodeName)
    }
    
    @Test("Test Empty Instructions Array")
    func testEmptyInstructionsArray() {
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
    
    @Test("Test Date Created After Date Modified")
    func testDateCreatedAfterDateModified() {
        let randomExerciseId = String.random
        let randomName = String.random
        let earlierDate = Date(timeIntervalSince1970: 1000000000)
        let laterDate = Date(timeIntervalSince1970: 2000000000)
        
        // This is an unusual case but the model should handle it
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            dateCreated: laterDate,
            dateModified: earlierDate
        )
        
        #expect(exercise.dateCreated == laterDate)
        #expect(exercise.dateModified == earlierDate)
    }
}
