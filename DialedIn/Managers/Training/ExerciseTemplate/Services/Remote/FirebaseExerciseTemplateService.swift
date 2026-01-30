//
//  FirebaseTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import FirebaseFirestore

struct FirebaseExerciseTemplateService: RemoteExerciseTemplateService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("exercise_templates")
    }
    
    func createExerciseTemplate(exercise: ExerciseModel, image: PlatformImage?) async throws {
        // Work on a mutable copy so any image URL updates are persisted
        var exerciseToSave = exercise
        
        if let image {
            // Upload the image
            let path = "exercise_templates/\(exercise.id)/image.jpg"
            let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
            // Persist the download URL on the exercise that will be saved
            exerciseToSave.updateImageURL(imageUrl: url.absoluteString)
        }
        
        // Upload the (possibly updated) exercise
        try collection.document(exerciseToSave.id).setData(from: exerciseToSave, merge: true)
        try await collection.document(exerciseToSave.id).setData([
            "name_lower": exerciseToSave.name.lowercased()
        ], merge: true)
    }
    
    func getExerciseTemplate(id: String) async throws -> ExerciseModel {
        let document = try await collection.document(id).getDocument()
        return try document.data(as: ExerciseModel.self)
    }
    
    func getExerciseTemplates(ids: [String], limitTo: Int = 20) async throws -> [ExerciseModel] {
        // Fetch documents individually to handle missing/null documents gracefully
        var exercises: [ExerciseModel] = []
        
        for id in ids {
            do {
                let document = try await collection.document(id).getDocument()
                let exercise = try document.data(as: ExerciseModel.self)
                exercises.append(exercise)
            } catch {
                // Skip documents that don't exist or fail to decode
                // This prevents errors when user has bookmarked/favorited items that were deleted
                print("⚠️ Skipping exercise template \(id): \(error.localizedDescription)")
            }
        }
        
        return Array(exercises
            .shuffled()
            .prefix(limitTo))
    }
    
    func getExerciseTemplatesByName(name: String) async throws -> [ExerciseModel] {
        let lower = name.lowercased()
        // Case-insensitive prefix search using range on a lowercased field
        let snapshot = try await collection
            .order(by: "name_lower")
            .start(at: [lower])
            .end(at: [lower + "\u{f8ff}"])
            .limit(to: 25)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: ExerciseModel.self) }
    }
    
    func getExerciseTemplatesForAuthor(authorId: String) async throws -> [ExerciseModel] {
        let snapshot = try await collection
            .whereField(ExerciseModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .order(by: ExerciseModel.CodingKeys.dateCreated.rawValue, descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: ExerciseModel.self) }
    }
    
    func getTopExerciseTemplatesByClicks(limitTo: Int) async throws -> [ExerciseModel] {
        let snapshot = try await collection
            .order(by: ExerciseModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: limitTo)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: ExerciseModel.self) }
    }
    
    func incrementExerciseTemplateInteraction(id: String) async throws {
        try await collection
            .document(id)
            .updateData([
            ExerciseModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
        ])
    }
    
    func removeAuthorIdFromExerciseTemplate(id: String) async throws {
        try await collection.document(id).updateData([
            ExerciseModel.CodingKeys.authorId.rawValue: NSNull()
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
            ExerciseModel.CodingKeys.bookmarkCount.rawValue: FieldValue.increment(Int64(isBookmarked ? 1 : -1))
        ])
    }

    func favouriteExerciseTemplate(id: String, isFavourited: Bool) async throws {
        try await collection.document(id).updateData([
            ExerciseModel.CodingKeys.favouriteCount.rawValue: FieldValue.increment(Int64(isFavourited ? 1 : -1))
        ])
    }
}
