//
//  ExerciseTemplateModelCodableAndProtocolTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation

struct ExerciseTemplateCodableTests {

    // MARK: - Identifiable Tests
    
    @Test("Test ExerciseTemplateModel Is Identifiable")
    func testExerciseTemplateModelIsIdentifiable() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.id == randomExerciseId)
        #expect(exercise.exerciseId == randomExerciseId)
    }
    
    // MARK: - Mutating Function Tests
    
    @Test("Test Update Image URL")
    func testUpdateImageURL() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        let randomImageUrl = "https://example.com/\(String.random).jpg"
        
        var exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        #expect(exercise.imageURL == nil)
        
        exercise.updateImageURL(imageUrl: randomImageUrl)
        
        #expect(exercise.imageURL == randomImageUrl)
    }
    
    @Test("Test Update Image URL Multiple Times")
    func testUpdateImageURLMultipleTimes() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        let firstImageUrl = "https://example.com/first.jpg"
        let secondImageUrl = "https://example.com/second.jpg"
        
        var exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        exercise.updateImageURL(imageUrl: firstImageUrl)
        #expect(exercise.imageURL == firstImageUrl)
        
        exercise.updateImageURL(imageUrl: secondImageUrl)
        #expect(exercise.imageURL == secondImageUrl)
    }
    
    // MARK: - Codable Tests
    
    @Test("Test Encoding And Decoding")
    func testEncodingAndDecoding() throws {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomAuthorId = String.random
        let randomDescription = String.random
        let randomInstructions = ["Step 1", "Step 2"]
        let randomImageUrl = "https://example.com/\(String.random).jpg"
        let randomDateCreated = Date.random
        let randomDateModified = Date.random
        
        let originalExercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            authorId: randomAuthorId,
            name: randomName,
            description: randomDescription,
            instructions: randomInstructions,
            type: .barbell,
            muscleGroups: [.chest, .arms],
            imageURL: randomImageUrl,
            isSystemExercise: true,
            dateCreated: randomDateCreated,
            dateModified: randomDateModified,
            clickCount: 10,
            bookmarkCount: 5,
            favouriteCount: 2
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let encodedData = try encoder.encode(originalExercise)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let decodedExercise = try decoder.decode(ExerciseTemplateModel.self, from: encodedData)
        
        // With millisecondsSince1970, dates preserve sub-second precision
        #expect(decodedExercise.exerciseId == originalExercise.exerciseId)
        #expect(decodedExercise.authorId == originalExercise.authorId)
        #expect(decodedExercise.name == originalExercise.name)
        #expect(decodedExercise.description == originalExercise.description)
        #expect(decodedExercise.instructions == originalExercise.instructions)
        #expect(decodedExercise.type == originalExercise.type)
        #expect(decodedExercise.muscleGroups == originalExercise.muscleGroups)
        #expect(decodedExercise.imageURL == originalExercise.imageURL)
        #expect(decodedExercise.isSystemExercise == originalExercise.isSystemExercise)
        #expect(abs(decodedExercise.dateCreated.timeIntervalSince1970 - originalExercise.dateCreated.timeIntervalSince1970) < 0.001)
        #expect(abs(decodedExercise.dateModified.timeIntervalSince1970 - originalExercise.dateModified.timeIntervalSince1970) < 0.001)
        #expect(decodedExercise.clickCount == originalExercise.clickCount)
        #expect(decodedExercise.bookmarkCount == originalExercise.bookmarkCount)
        #expect(decodedExercise.favouriteCount == originalExercise.favouriteCount)
    }
    
    @Test("Test Coding Keys Mapping")
    func testCodingKeysMapping() throws {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomAuthorId = String.random
        let randomDate = Date.random
        
        let exercise = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            authorId: randomAuthorId,
            name: randomName,
            description: "Test description",
            instructions: ["Step 1", "Step 2"],
            type: .barbell,
            muscleGroups: [.chest, .arms],
            imageURL: "https://example.com/image.jpg",
            isSystemExercise: true,
            dateCreated: randomDate,
            dateModified: randomDate,
            clickCount: 10,
            bookmarkCount: 5,
            favouriteCount: 2
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let encodedData = try encoder.encode(exercise)
        
        let json = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any]
        
        #expect(json?["exercise_id"] as? String == randomExerciseId)
        #expect(json?["author_id"] as? String == randomAuthorId)
        #expect(json?["name"] as? String == randomName)
        #expect(json?["description"] as? String == "Test description")
        #expect(json?["instructions"] as? [String] == ["Step 1", "Step 2"])
        #expect(json?["type"] as? String == "barbell")
        #expect(json?["muscle_groups"] as? [String] == ["chest", "arms"])
        #expect(json?["image_url"] as? String == "https://example.com/image.jpg")
        #expect(json?["is_system_exercise"] as? Bool == true)
        #expect(json?["click_count"] as? Int == 10)
        #expect(json?["bookmark_count"] as? Int == 5)
        #expect(json?["favourite_count"] as? Int == 2)
    }
    
    @Test("Test Decoding With Missing Optional Fields")
    func testDecodingWithMissingOptionalFields() throws {
        let json: [String: Any] = [
            "name": "Test Exercise"
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        let exercise = try decoder.decode(ExerciseTemplateModel.self, from: jsonData)
        
        #expect(exercise.name == "Test Exercise")
        #expect(!exercise.exerciseId.isEmpty) // Should generate a UUID
        #expect(exercise.authorId == nil)
        #expect(exercise.description == nil)
        #expect(exercise.instructions.isEmpty)
        #expect(exercise.type == .none)
        #expect(exercise.muscleGroups.isEmpty)
        #expect(exercise.imageURL == nil)
        #expect(exercise.isSystemExercise == false)
        #expect(exercise.clickCount == 0)
        #expect(exercise.bookmarkCount == 0)
        #expect(exercise.favouriteCount == 0)
    }
    
    @Test("Test Decoding With Partial Fields")
    func testDecodingWithPartialFields() throws {
        let json: [String: Any] = [
            "exercise_id": "test-id",
            "name": "Partial Exercise",
            "type": "dumbbell",
            "muscle_groups": ["chest"],
            "is_system_exercise": true
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: json)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        
        let exercise = try decoder.decode(ExerciseTemplateModel.self, from: jsonData)
        
        #expect(exercise.exerciseId == "test-id")
        #expect(exercise.name == "Partial Exercise")
        #expect(exercise.type == .dumbbell)
        #expect(exercise.muscleGroups == [.chest])
        #expect(exercise.isSystemExercise == true)
    }
    
    // MARK: - Hashable Tests
    
    @Test("Test Hashable Conformance")
    func testHashableConformance() {
        let randomExerciseId = String.random
        let randomName = String.random
        let randomDate = Date.random
        
        let exercise1 = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        let exercise2 = ExerciseTemplateModel(
            exerciseId: randomExerciseId,
            name: randomName,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        var hashSet = Set<ExerciseTemplateModel>()
        hashSet.insert(exercise1)
        hashSet.insert(exercise2)
        
        // Should only have one element since they're equal
        #expect(hashSet.count == 1)
    }
    
    @Test("Test Hashable With Different IDs")
    func testHashableWithDifferentIDs() {
        let randomName = String.random
        let randomDate = Date.random
        
        let exercise1 = ExerciseTemplateModel(
            exerciseId: String.random,
            name: randomName,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        let exercise2 = ExerciseTemplateModel(
            exerciseId: String.random,
            name: randomName,
            dateCreated: randomDate,
            dateModified: randomDate
        )
        
        var hashSet = Set<ExerciseTemplateModel>()
        hashSet.insert(exercise1)
        hashSet.insert(exercise2)
        
        // Should have two elements since they have different IDs
        #expect(hashSet.count == 2)
    }
}
