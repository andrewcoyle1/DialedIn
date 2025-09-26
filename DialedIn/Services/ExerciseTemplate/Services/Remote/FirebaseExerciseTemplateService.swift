//
//  FirebaseTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseExerciseTemplateService: RemoteExerciseTemplateService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("exercise_templates")
    }
    
    func createExerciseTemplate(exercise: ExerciseTemplateModel, image: PlatformImage?) async throws {
        // Work on a mutable copy so any image URL updates are persisted
        var exerciseToSave = exercise
        
        if let image {
            // Upload the image
            let path = "exercise_templates/\(exercise.id)"
            let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
            
            // Persist the download URL on the exercise that will be saved
            exerciseToSave.updateImageURL(imageUrl: url.absoluteString)
        }
        
        // Upload the (possibly updated) exercise
        try collection.document(exerciseToSave.id).setData(from: exerciseToSave, merge: true)
        // Also persist lowercased name for case-insensitive prefix search
        try await collection.document(exerciseToSave.id).setData([
            "name_lower": exerciseToSave.name.lowercased()
        ], merge: true)
    }
    
    func getExerciseTemplate(id: String) async throws -> ExerciseTemplateModel {
        try await collection.getDocument(id: id)
    }
    
    func getExerciseTemplates(ids: [String], limitTo: Int = 20) async throws -> [ExerciseTemplateModel] {
        try await collection
            .getDocuments(ids: ids)
            .shuffled()
            .first(upTo: limitTo) ?? []
    }
    
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseTemplateModel] {
        let lower = name.lowercased()
        // Case-insensitive prefix search using range on a lowercased field
        return try await collection
            .order(by: "name_lower")
            .start(at: [lower])
            .end(at: [lower + "\u{f8ff}"])
            .limit(to: 25)
            .getAllDocuments()
    }
    
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseTemplateModel] {
        try await collection
            .whereField(ExerciseTemplateModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .order(by: ExerciseTemplateModel.CodingKeys.dateCreated.rawValue, descending: true)
            .getAllDocuments()
    }
    
    func getTopExerciseTemplatesByClicks(limitTo: Int) async throws -> [ExerciseTemplateModel] {
        try await collection
            .order(by: ExerciseTemplateModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: limitTo)
            .getAllDocuments()
    }
    
    func incrementExerciseTemplateInteraction(id: String) async throws {
        try await collection
            .document(id)
            .updateData([
            ExerciseTemplateModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
        ])
    }
    
    func removeAuthorIdFromExerciseTemplate(id: String) async throws {
        try await collection.document(id).updateData([
            ExerciseTemplateModel.CodingKeys.authorId.rawValue: NSNull()
        ])
    }
    
    func removeAuthorIdFromAllExerciseTemplates(id: String) async throws {
        let exercises = try await getExerciseTemplatesForAuthor(authorId: id)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for exercise in exercises {
                group.addTask {
                    try await removeAuthorIdFromExerciseTemplate(id: exercise.id)
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    func bookmarkExerciseTemplate(id: String, isBookmarked: Bool) async throws {
        try await collection.document(id).updateData([
            ExerciseTemplateModel.CodingKeys.bookmarkCount.rawValue: FieldValue.increment(Int64(isBookmarked ? 1 : -1))
        ])
    }

    func favouriteExerciseTemplate(id: String, isFavourited: Bool) async throws {
        try await collection.document(id).updateData([
            ExerciseTemplateModel.CodingKeys.favouriteCount.rawValue: FieldValue.increment(Int64(isFavourited ? 1 : -1))
        ])
    }
}
