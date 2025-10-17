//
//  FirebaseTemplateService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import FirebaseFirestore
import SwiftfulFirestore

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
    
    func getWorkoutTemplate(id: String) async throws -> WorkoutTemplateModel {
        try await collection.getDocument(id: id)
    }
    
    func getWorkoutTemplates(ids: [String], limitTo: Int = 20) async throws -> [WorkoutTemplateModel] {
        // Fetch documents individually to handle missing/null documents gracefully
        var workouts: [WorkoutTemplateModel] = []
        
        for id in ids {
            do {
                let workout = try await collection.getDocument(id: id) as WorkoutTemplateModel
                workouts.append(workout)
            } catch {
                // Skip documents that don't exist or fail to decode
                // This prevents errors when user has bookmarked/favorited items that were deleted
                print("⚠️ Skipping workout template \(id): \(error.localizedDescription)")
            }
        }
        
        return workouts
            .shuffled()
            .first(upTo: limitTo) ?? []
    }
    
    func getWorkoutTemplatesByName(name: String) async throws -> [WorkoutTemplateModel] {
        let lower = name.lowercased()
        // Case-insensitive prefix search using range on a lowercased field
        return try await collection
            .order(by: "name_lower")
            .start(at: [lower])
            .end(at: [lower + "\u{f8ff}"])
            .limit(to: 25)
            .getAllDocuments()
    }
    
    func getWorkoutTemplatesForAuthor(authorId: String) async throws -> [WorkoutTemplateModel] {
        try await collection
            .whereField(ExerciseTemplateModel.CodingKeys.authorId.rawValue, isEqualTo: authorId)
            .order(by: ExerciseTemplateModel.CodingKeys.dateCreated.rawValue, descending: true)
            .getAllDocuments()
    }
    
    func getTopWorkoutTemplatesByClicks(limitTo: Int) async throws -> [WorkoutTemplateModel] {
        try await collection
            .order(by: WorkoutTemplateModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: limitTo)
            .getAllDocuments()
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
