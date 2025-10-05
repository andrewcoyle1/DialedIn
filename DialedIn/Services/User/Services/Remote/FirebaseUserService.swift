//
//  FirebaseUserService.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/15/24.
//
import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseUserService: RemoteUserService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel, image: PlatformImage? = nil) async throws {
        if let image {
            // Upload the image
            let path = "users/\(user.userId)/profile.jpg"
            let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
            
            // Update user image name
            var user = user
            user.updateImageURL(imageUrl: url.absoluteString)
        }
        // Upload the user
        try collection.document(user.userId).setData(from: user, merge: true)
    }
    
    func markUnanonymous(userId: String, email: String? = nil) async throws {
        var data: [String: Any] = [
            UserModel.CodingKeys.isAnonymous.rawValue: false
        ]
        if let email {
            data[UserModel.CodingKeys.email.rawValue] = email
        } 

        try await collection.document(userId).updateData(data)
    }
    
    func updateFirstName(userId: String, firstName: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.firstName.rawValue: firstName
        ])
    }
    
    func updateLastName(userId: String, lastName: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.lastName.rawValue: lastName
        ])
    }
    
    func updateDateOfBirth(userId: String, dateOfBirth: Date) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.dateOfBirth.rawValue: dateOfBirth
        ])
    }
    
    func updateGender(userId: String, gender: Gender) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.gender.rawValue: gender.rawValue
        ])
    }
    
    func updateProfileImageUrl(userId: String, url: String?) async throws {
        var data: [String: Any] = [:]
        if let url {
            data[UserModel.CodingKeys.profileImageUrl.rawValue] = url
        } else {
            data[UserModel.CodingKeys.profileImageUrl.rawValue] = FieldValue.delete()
        }
        try await collection.document(userId).updateData(data)
    }
    
    func updateLastSignInDate(userId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.lastSignInDate.rawValue: Date()
        ])
    }
    
    func markOnboardingCompleted(userId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true
        ])
    }
    
    // MARK: - Goal Settings
    func updateGoalSettings(userId: String, objective: String, targetWeightKilograms: Double, weeklyChangeKilograms: Double) async throws {
        let data: [String: Any] = [
            "goal_objective": objective,
            "goal_target_weight_kg": targetWeightKilograms,
            "goal_weekly_change_kg": weeklyChangeKilograms
        ]
        try await collection.document(userId).updateData(data)
    }
    
    // MARK: - Created/Bookmarked/Favourited Exercise Templates
    
    func addCreatedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.createdExerciseTemplateIds.rawValue: FieldValue.arrayUnion([exerciseTemplateId])
        ])
    }
    
    func removeCreatedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.createdExerciseTemplateIds.rawValue: FieldValue.arrayRemove([exerciseTemplateId])
        ])
    }
    
    func addBookmarkedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.bookmarkedExerciseTemplateIds.rawValue: FieldValue.arrayUnion([exerciseTemplateId])
        ])
    }
    
    func removeBookmarkedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.bookmarkedExerciseTemplateIds.rawValue: FieldValue.arrayRemove([exerciseTemplateId])
        ])
    }
    
    func addFavouritedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.favouritedExerciseTemplateIds.rawValue: FieldValue.arrayUnion([exerciseTemplateId])
        ])
    }
    
    func removeFavouritedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.favouritedExerciseTemplateIds.rawValue: FieldValue.arrayRemove([exerciseTemplateId])
        ])
    }
    
    func addCreatedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.createdWorkoutTemplateIds.rawValue: FieldValue.arrayUnion([workoutTemplateId])
        ])
    }
    
    func removeCreatedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.createdWorkoutTemplateIds.rawValue: FieldValue.arrayRemove([workoutTemplateId])
        ])
    }
    
    func addBookmarkedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.bookmarkedWorkoutTemplateIds.rawValue: FieldValue.arrayUnion([workoutTemplateId])
        ])
    }
    
    func removeBookmarkedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.bookmarkedWorkoutTemplateIds.rawValue: FieldValue.arrayRemove([workoutTemplateId])
        ])
    }
    
    func addFavouritedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.favouritedWorkoutTemplateIds.rawValue: FieldValue.arrayUnion([workoutTemplateId])
        ])
    }
    
    func removeFavouritedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.favouritedWorkoutTemplateIds.rawValue: FieldValue.arrayRemove([workoutTemplateId])
        ])
    }
    
    // MARK: - Created/Bookmarked/Favourited Ingredient Templates

    func addCreatedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.createdIngredientTemplateIds.rawValue: FieldValue.arrayUnion([ingredientTemplateId])
        ])
    }

    func removeCreatedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.createdIngredientTemplateIds.rawValue: FieldValue.arrayRemove([ingredientTemplateId])
        ])
    }

    func addBookmarkedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.bookmarkedIngredientTemplateIds.rawValue: FieldValue.arrayUnion([ingredientTemplateId])
        ])
    }

    func removeBookmarkedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.bookmarkedIngredientTemplateIds.rawValue: FieldValue.arrayRemove([ingredientTemplateId])
        ])
    }

    func addFavouritedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.favouritedIngredientTemplateIds.rawValue: FieldValue.arrayUnion([ingredientTemplateId])
        ])
    }

    func removeFavouritedIngredientTemplate(userId: String, ingredientTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.favouritedIngredientTemplateIds.rawValue: FieldValue.arrayRemove([ingredientTemplateId])
        ])
    }

    func addCreatedRecipeTemplate(userId: String, recipeTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.createdRecipeTemplateIds.rawValue: FieldValue.arrayUnion([recipeTemplateId])
        ])
    }

    func removeCreatedRecipeTemplate(userId: String, recipeTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.createdRecipeTemplateIds.rawValue: FieldValue.arrayRemove([recipeTemplateId])
        ])
    }

    func addBookmarkedRecipeTemplate(userId: String, recipeTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.bookmarkedRecipeTemplateIds.rawValue: FieldValue.arrayUnion([recipeTemplateId])
        ])
    }

    func removeBookmarkedRecipeTemplate(userId: String, recipeTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.bookmarkedRecipeTemplateIds.rawValue: FieldValue.arrayRemove([recipeTemplateId])
        ])
    }

    func addFavouritedRecipeTemplate(userId: String, recipeTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.favouritedRecipeTemplateIds.rawValue: FieldValue.arrayUnion([recipeTemplateId])
        ])
    }

    func removeFavouritedRecipeTemplate(userId: String, recipeTemplateId: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.favouritedRecipeTemplateIds.rawValue: FieldValue.arrayRemove([recipeTemplateId])
        ])
    }

    // MARK: - User blocking
    func blockUser(currentUserId: String, blockedUserId: String) async throws {
        try await collection.document(currentUserId).updateData([
            UserModel.CodingKeys.blockedUserIds.rawValue: FieldValue.arrayUnion([blockedUserId])
        ])
    }
    
    func unblockUser(currentUserId: String, blockedUserId: String) async throws {
        try await collection.document(currentUserId).updateData([
            UserModel.CodingKeys.blockedUserIds.rawValue: FieldValue.arrayRemove([blockedUserId])
        ])
    }
    
    // MARK: - User deletion
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
    
    // MARK: - User Streaming
    
//    func streamUser(userId: String, onListenerConfigured: @escaping (@escaping () -> Void) -> Void) -> AsyncThrowingStream<UserModel, Error> {
        func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
//        collection.streamDocument(id: userId, onListenerConfigured: { listener in
//            onListenerConfigured({ listener.remove() })
//        })
        collection.streamDocument(id: userId)

    }

    // MARK: - Consents
    func updateHealthConsents(userId: String, disclaimerVersion: String, privacyVersion: String, acceptedAt: Date) async throws {
        let data: [String: Any] = [
            "accepted_health_disclaimer_version": disclaimerVersion,
            "accepted_health_disclaimer_at": acceptedAt,
            "accepted_health_privacy_version": privacyVersion,
            "accepted_health_privacy_at": acceptedAt
        ]
        try await collection.document(userId).updateData(data)
    }
}
