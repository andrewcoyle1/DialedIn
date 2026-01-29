//
//  FirebaseTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import FirebaseFirestore

struct FirebaseWorkoutTemplateService: RemoteWorkoutTemplateService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("workout_templates")
    }
    
    func createWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws {
        // Work on a mutable copy so any image URL updates are persisted
        var workoutToSave = workout
        
        if let image {
            // Upload the image
            let path = "workout_templates/\(workout.id)/image.jpg"
            let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
            
            // Persist the download URL on the exercise that will be saved
            workoutToSave.updateImageURL(imageUrl: url.absoluteString)
        }
        
        // Upload the (possibly updated) exercise
        try collection.document(workoutToSave.id).setData(from: workoutToSave, merge: true)
        // Also persist lowercased name for case-insensitive prefix search
        try await collection.document(
            workoutToSave.id).setData([
            "name_lower": workoutToSave.name.lowercased()
        ], merge: true)
    }
    
    func updateWorkoutTemplate(workout: WorkoutTemplateModel, image: PlatformImage?) async throws {
        // Work on a mutable copy so any image URL updates are persisted
        var workoutToUpdate = workout
        
        if let image {
            // Upload the image
            let path = "workout_templates/\(workout.id)/image.jpg"
            let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
            
            // Persist the download URL on the workout that will be saved
            workoutToUpdate.updateImageURL(imageUrl: url.absoluteString)
        }
        
        // Update dateModified
        workoutToUpdate.updateDateModified(dateModified: Date())
        
        // Upload the (possibly updated) workout
        try collection.document(workoutToUpdate.id).setData(from: workoutToUpdate, merge: true)
        // Also persist lowercased name for case-insensitive prefix search
        try await collection.document(
            workoutToUpdate.id).setData([
            "name_lower": workoutToUpdate.name.lowercased()
        ], merge: true)
    }
    
    func deleteWorkoutTemplate(id: String) async throws {
        // Delete the image if it exists
        do {
            try await FirebaseImageUploadService().deleteImage(path: "workout_templates/\(id)/image.jpg")
        } catch {
            // Ignore if image doesn't exist
            print("⚠️ No image to delete for workout template \(id)")
        }
        
        // Delete the document
        try await collection.document(id).delete()
    }
    
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel {
        let document = try await collection.document(id).getDocument()
        return try document.data(as: WorkoutTemplateModel.self)
    }
    
    func getWorkoutTemplates(ids: [String], limitTo: Int = 20) async throws -> [WorkoutTemplateModel] {
        // Fetch documents individually to handle missing/null documents gracefully
        var workouts: [WorkoutTemplateModel] = []
        
        for id in ids {
            do {
                let document = try await collection.document(id).getDocument()
                let workout = try document.data(as: WorkoutTemplateModel.self)
                workouts.append(workout)
            } catch {
                // Skip documents that don't exist or fail to decode
                // This prevents errors when user has bookmarked/favorited items that were deleted
                print("⚠️ Skipping workout template \(id): \(error.localizedDescription)")
            }
        }
        
        return Array(workouts
            .shuffled()
            .prefix(limitTo))
    }
    
    func getWorkoutTemplatesByName(name: String) async throws -> [WorkoutTemplateModel] {
        let lower = name.lowercased()
        // Case-insensitive prefix search using range on a lowercased field
        let snapshot = try await collection
            .order(by: "name_lower")
            .start(at: [lower])
            .end(at: [lower + "\u{f8ff}"])
            .limit(to: 25)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: WorkoutTemplateModel.self) }
    }
    
    func getWorkoutTemplatesForAuthor(authorId: String) async throws -> [WorkoutTemplateModel] {
        let snapshot = try await collection
            .whereField(ExerciseTemplateModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .order(by: ExerciseTemplateModel.CodingKeys.dateCreated.rawValue, descending: true)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: WorkoutTemplateModel.self) }
    }
    
    func getTopWorkoutTemplatesByClicks(limitTo: Int) async throws -> [WorkoutTemplateModel] {
        let snapshot = try await collection
            .order(by: WorkoutTemplateModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: limitTo)
            .getDocuments()
        
        return try snapshot.documents.compactMap { try $0.data(as: WorkoutTemplateModel.self) }
    }
    
    func incrementWorkoutTemplateInteraction(id: String) async throws {
        try await collection
            .document(id)
            .updateData([
                WorkoutTemplateModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
        ])
    }
    
    func removeAuthorIdFromWorkoutTemplate(id: String) async throws {
        try await collection.document(id).updateData([
            WorkoutTemplateModel.CodingKeys.authorId.rawValue: NSNull()
        ])
    }
    
    func removeAuthorIdFromAllWorkoutTemplates(id: String) async throws {
        let workouts = try await getWorkoutTemplatesForAuthor(authorId: id)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for workout in workouts {
                group.addTask {
                    try await removeAuthorIdFromWorkoutTemplate(id: workout.id)
                }
            }
            
            try await group.waitForAll()
        }
    }
    
    func bookmarkWorkoutTemplate(id: String, isBookmarked: Bool) async throws {
        try await collection.document(id).updateData([
            WorkoutTemplateModel.CodingKeys.bookmarkCount.rawValue: FieldValue.increment(Int64(isBookmarked ? 1 : -1))
        ])
    }

    func favouriteWorkoutTemplate(id: String, isFavourited: Bool) async throws {
        try await collection.document(id).updateData([
            WorkoutTemplateModel.CodingKeys.favouriteCount.rawValue: FieldValue.increment(Int64(isFavourited ? 1 : -1))
        ])
    }
}
