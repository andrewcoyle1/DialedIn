//
//  ExerciseTemplateEnumTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation

struct ExerciseCategoryTests {

    // MARK: - ExerciseCategory Raw Value Tests
    
    @Test("Test ExerciseCategory Raw Values")
    func testExerciseCategoryRawValues() {
        #expect(ExerciseCategory.barbell.rawValue == "barbell")
        #expect(ExerciseCategory.dumbbell.rawValue == "dumbbell")
        #expect(ExerciseCategory.kettlebell.rawValue == "kettlebell")
        #expect(ExerciseCategory.medicineBall.rawValue == "medicineBall")
        #expect(ExerciseCategory.machine.rawValue == "machine")
        #expect(ExerciseCategory.cable.rawValue == "cable")
        #expect(ExerciseCategory.weightedBodyweight.rawValue == "weightedBodyweight")
        #expect(ExerciseCategory.assistedBodyweight.rawValue == "assistedBodyweight")
        #expect(ExerciseCategory.repsOnly.rawValue == "repsOnly")
        #expect(ExerciseCategory.cardio.rawValue == "cardio")
        #expect(ExerciseCategory.duration.rawValue == "duration")
        #expect(ExerciseCategory.none.rawValue == "none")
    }
    
    @Test("Test ExerciseCategory Case Iterable")
    func testExerciseCategoryCaseIterable() {
        let allCases = ExerciseCategory.allCases
        #expect(allCases.count == 12)
        #expect(allCases.contains(.barbell))
        #expect(allCases.contains(.dumbbell))
        #expect(allCases.contains(.kettlebell))
        #expect(allCases.contains(.medicineBall))
        #expect(allCases.contains(.machine))
        #expect(allCases.contains(.cable))
        #expect(allCases.contains(.weightedBodyweight))
        #expect(allCases.contains(.assistedBodyweight))
        #expect(allCases.contains(.repsOnly))
        #expect(allCases.contains(.cardio))
        #expect(allCases.contains(.duration))
        #expect(allCases.contains(.none))
    }
    
    @Test("Test ExerciseCategory Descriptions")
    func testExerciseCategoryDescriptions() {
        #expect(ExerciseCategory.barbell.description == "Barbell")
        #expect(ExerciseCategory.dumbbell.description == "Dumbbell")
        #expect(ExerciseCategory.kettlebell.description == "Kettlebell")
        #expect(ExerciseCategory.medicineBall.description == "Medicine Ball")
        #expect(ExerciseCategory.machine.description == "Machine")
        #expect(ExerciseCategory.cable.description == "Cable")
        #expect(ExerciseCategory.weightedBodyweight.description == "Weighted Bodyweight")
        #expect(ExerciseCategory.assistedBodyweight.description == "Assisted Bodyweight")
        #expect(ExerciseCategory.repsOnly.description == "Reps Only")
        #expect(ExerciseCategory.cardio.description == "Cardio")
        #expect(ExerciseCategory.duration.description == "Duration")
        #expect(ExerciseCategory.none.description == "None")
    }
    
    @Test("Test ExerciseCategory Codable")
    func testExerciseCategoryCodable() throws {
        let categories: [ExerciseCategory] = [.barbell, .dumbbell, .cardio, .none]
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(categories)
        
        let decoder = JSONDecoder()
        let decodedCategories = try decoder.decode([ExerciseCategory].self, from: encodedData)
        
        #expect(decodedCategories == categories)
    }
    
    @Test("Test ExerciseCategory Decoding From String")
    func testExerciseCategoryDecodingFromString() throws {
        let json = "\"barbell\""
        let jsonData = json.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let category = try decoder.decode(ExerciseCategory.self, from: jsonData)
        
        #expect(category == .barbell)
    }
    
    @Test("Test ExerciseCategory Encoding To String")
    func testExerciseCategoryEncodingToString() throws {
        let category = ExerciseCategory.dumbbell
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(category)
        let encodedString = String(data: encodedData, encoding: .utf8)
        
        #expect(encodedString == "\"dumbbell\"")
    }
    
    @Test("Test All Exercise Categories Have Non-Empty Descriptions")
    func testAllExerciseCategoriesHaveNonEmptyDescriptions() {
        for category in ExerciseCategory.allCases {
            #expect(!category.description.isEmpty)
        }
    }
    
    @Test("Test All Exercise Categories Have Unique Descriptions")
    func testAllExerciseCategoriesHaveUniqueDescriptions() {
        let descriptions = ExerciseCategory.allCases.map { $0.description }
        let uniqueDescriptions = Set(descriptions)
        #expect(descriptions.count == uniqueDescriptions.count)
    }
    
    @Test("Test Exercise Category Equality")
    func testExerciseCategoryEquality() {
        #expect(ExerciseCategory.barbell == ExerciseCategory.barbell)
        #expect(ExerciseCategory.barbell != ExerciseCategory.dumbbell)
        #expect(ExerciseCategory.none == ExerciseCategory.none)
    }
}

struct MuscleGroupTests {

    // MARK: - MuscleGroup Raw Value Tests
    
    @Test("Test MuscleGroup Raw Values")
    func testMuscleGroupRawValues() {
        #expect(MuscleGroup.chest.rawValue == "chest")
        #expect(MuscleGroup.shoulders.rawValue == "shoulders")
        #expect(MuscleGroup.back.rawValue == "back")
        #expect(MuscleGroup.arms.rawValue == "arms")
        #expect(MuscleGroup.legs.rawValue == "legs")
        #expect(MuscleGroup.core.rawValue == "core")
        #expect(MuscleGroup.none.rawValue == "none")
    }
    
    @Test("Test MuscleGroup Case Iterable")
    func testMuscleGroupCaseIterable() {
        let allCases = MuscleGroup.allCases
        #expect(allCases.count == 7)
        #expect(allCases.contains(.chest))
        #expect(allCases.contains(.shoulders))
        #expect(allCases.contains(.back))
        #expect(allCases.contains(.arms))
        #expect(allCases.contains(.legs))
        #expect(allCases.contains(.core))
        #expect(allCases.contains(.none))
    }
    
    @Test("Test MuscleGroup Descriptions")
    func testMuscleGroupDescriptions() {
        #expect(MuscleGroup.chest.description == "Chest")
        #expect(MuscleGroup.shoulders.description == "Shoulders")
        #expect(MuscleGroup.back.description == "Back")
        #expect(MuscleGroup.arms.description == "Arms")
        #expect(MuscleGroup.legs.description == "Legs")
        #expect(MuscleGroup.core.description == "Core")
        #expect(MuscleGroup.none.description == "None")
    }
    
    @Test("Test MuscleGroup Codable")
    func testMuscleGroupCodable() throws {
        let muscleGroups: [MuscleGroup] = [.chest, .back, .legs, .core]
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(muscleGroups)
        
        let decoder = JSONDecoder()
        let decodedMuscleGroups = try decoder.decode([MuscleGroup].self, from: encodedData)
        
        #expect(decodedMuscleGroups == muscleGroups)
    }
    
    @Test("Test MuscleGroup Decoding From String")
    func testMuscleGroupDecodingFromString() throws {
        let json = "\"chest\""
        let jsonData = json.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let muscleGroup = try decoder.decode(MuscleGroup.self, from: jsonData)
        
        #expect(muscleGroup == .chest)
    }
    
    @Test("Test MuscleGroup Encoding To String")
    func testMuscleGroupEncodingToString() throws {
        let muscleGroup = MuscleGroup.arms
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(muscleGroup)
        let encodedString = String(data: encodedData, encoding: .utf8)
        
        #expect(encodedString == "\"arms\"")
    }
    
    @Test("Test All Muscle Groups Have Non-Empty Descriptions")
    func testAllMuscleGroupsHaveNonEmptyDescriptions() {
        for muscleGroup in MuscleGroup.allCases {
            #expect(!muscleGroup.description.isEmpty)
        }
    }
    
    @Test("Test All Muscle Groups Have Unique Descriptions")
    func testAllMuscleGroupsHaveUniqueDescriptions() {
        let descriptions = MuscleGroup.allCases.map { $0.description }
        let uniqueDescriptions = Set(descriptions)
        #expect(descriptions.count == uniqueDescriptions.count)
    }
    
    @Test("Test Muscle Group Equality")
    func testMuscleGroupEquality() {
        #expect(MuscleGroup.chest == MuscleGroup.chest)
        #expect(MuscleGroup.chest != MuscleGroup.back)
        #expect(MuscleGroup.none == MuscleGroup.none)
    }
    
    @Test("Test Muscle Groups In Array")
    func testMuscleGroupsInArray() {
        let muscleGroups: [MuscleGroup] = [.chest, .shoulders, .arms]
        
        #expect(muscleGroups.contains(.chest))
        #expect(muscleGroups.contains(.shoulders))
        #expect(muscleGroups.contains(.arms))
        #expect(!muscleGroups.contains(.back))
    }
    
    @Test("Test Muscle Groups In Set")
    func testMuscleGroupsInSet() {
        let muscleGroupSet: Set<MuscleGroup> = [.chest, .chest, .arms, .arms]
        
        // Set should only have unique values
        #expect(muscleGroupSet.count == 2)
        #expect(muscleGroupSet.contains(.chest))
        #expect(muscleGroupSet.contains(.arms))
    }
}

struct ExerciseTemplateEnumIntegrationTests {

    // MARK: - Integration Tests
    
    @Test("Test ExerciseTemplateModel With All Exercise Categories")
    func testExerciseTemplateModelWithAllExerciseCategories() {
        for category in ExerciseCategory.allCases {
            let exercise = ExerciseTemplateModel(
                exerciseId: String.random,
                name: "Test \(category.description)",
                type: category,
                dateCreated: Date.random,
                dateModified: Date.random
            )
            
            #expect(exercise.type == category)
        }
    }
    
    @Test("Test ExerciseTemplateModel With All Muscle Groups")
    func testExerciseTemplateModelWithAllMuscleGroups() {
        for muscleGroup in MuscleGroup.allCases {
            let exercise = ExerciseTemplateModel(
                exerciseId: String.random,
                name: "Test \(muscleGroup.description)",
                muscleGroups: [muscleGroup],
                dateCreated: Date.random,
                dateModified: Date.random
            )
            
            #expect(exercise.muscleGroups.contains(muscleGroup))
        }
    }
    
    @Test("Test ExerciseTemplateModel With Multiple Muscle Groups")
    func testExerciseTemplateModelWithMultipleMuscleGroups() {
        let allMainMuscleGroups: [MuscleGroup] = [.chest, .shoulders, .back, .arms, .legs, .core]
        
        let exercise = ExerciseTemplateModel(
            exerciseId: String.random,
            name: "Full Body Exercise",
            muscleGroups: allMainMuscleGroups,
            dateCreated: Date.random,
            dateModified: Date.random
        )
        
        #expect(exercise.muscleGroups.count == 6)
        for muscleGroup in allMainMuscleGroups {
            #expect(exercise.muscleGroups.contains(muscleGroup))
        }
    }
    
    @Test("Test Exercise Category And Muscle Group Encoding Together")
    func testExerciseCategoryAndMuscleGroupEncodingTogether() throws {
        let exercise = ExerciseTemplateModel(
            exerciseId: String.random,
            name: "Bench Press",
            type: .barbell,
            muscleGroups: [.chest, .arms],
            dateCreated: Date.random,
            dateModified: Date.random
        )
        
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(exercise)
        
        let decoder = JSONDecoder()
        let decodedExercise = try decoder.decode(ExerciseTemplateModel.self, from: encodedData)
        
        #expect(decodedExercise.type == .barbell)
        #expect(decodedExercise.muscleGroups == [.chest, .arms])
    }
    
    @Test("Test Common Exercise Category And Muscle Group Combinations")
    func testCommonExerciseCategoryAndMuscleGroupCombinations() {
        // Bench Press - Barbell, Chest & Arms
        let benchPress = ExerciseTemplateModel(
            exerciseId: String.random,
            name: "Bench Press",
            type: .barbell,
            muscleGroups: [.chest, .arms],
            dateCreated: Date.random,
            dateModified: Date.random
        )
        #expect(benchPress.type == .barbell)
        #expect(benchPress.muscleGroups == [.chest, .arms])
        
        // Squat - Barbell, Legs & Core
        let squat = ExerciseTemplateModel(
            exerciseId: String.random,
            name: "Squat",
            type: .barbell,
            muscleGroups: [.legs, .core],
            dateCreated: Date.random,
            dateModified: Date.random
        )
        #expect(squat.type == .barbell)
        #expect(squat.muscleGroups == [.legs, .core])
        
        // Running - Cardio, Legs
        let running = ExerciseTemplateModel(
            exerciseId: String.random,
            name: "Running",
            type: .cardio,
            muscleGroups: [.legs],
            dateCreated: Date.random,
            dateModified: Date.random
        )
        #expect(running.type == .cardio)
        #expect(running.muscleGroups == [.legs])
        
        // Plank - Bodyweight, Core
        let plank = ExerciseTemplateModel(
            exerciseId: String.random,
            name: "Plank",
            type: .weightedBodyweight,
            muscleGroups: [.core],
            dateCreated: Date.random,
            dateModified: Date.random
        )
        #expect(plank.type == .weightedBodyweight)
        #expect(plank.muscleGroups == [.core])
    }
}
