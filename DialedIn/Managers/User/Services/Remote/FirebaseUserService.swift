//
//  FirebaseUserService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/15/24.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseUserService: RemoteUserService {    
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func getUser(userId: String) async throws -> UserModel {
        try await collection.getDocument(id: userId)
    }

    func saveUser(user: UserModel) async throws {
        try collection.document(user.userId).setData(from: user, merge: true)
    }

    func saveUserName(userId: String, firstName: String? = nil, lastName: String? = nil) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.firstName.rawValue: firstName as Any,
            UserModel.CodingKeys.lastName.rawValue: lastName as Any
        ])
    }
    
    func saveUserEmail(userId: String, email: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedEmail.rawValue: email
        ])
    }

    func saveUserProfileImage(userId: String, image: PlatformImage) async throws {
        // Upload the image
        let path = "users/\(userId)/profile"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
        
        // Update user document with image url string
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedProfileImage.rawValue: url.absoluteString
        ])
    }

    func saveUserGender(userId: String, gender: Gender) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedGender.rawValue: gender
        ])
    }

    func saveUserDateOfBirth(userId: String, dateOfBirth: Date) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedDateOfBirth.rawValue: dateOfBirth
        ])
    }

    func saveUserHeightCentimeters(userId: String, heightInCentimeters: Double, lengthUnitPreference: LengthUnitPreference) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedHeightCentimeters.rawValue: heightInCentimeters,
            UserModel.CodingKeys.submittedLengthUnitPreference.rawValue: lengthUnitPreference.rawValue
        ])
    }
    
    func saveUserLengthUnitPreference(userId: String, lengthUnitPreference: LengthUnitPreference) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedLengthUnitPreference.rawValue: lengthUnitPreference.rawValue
        ])
    }

    func saveUserWeightKilograms(userId: String, weightInKilograms: Double, weightUnitPreference: WeightUnitPreference) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedWeightKilograms.rawValue: weightInKilograms,
            UserModel.CodingKeys.submittedWeightUnitPreference.rawValue: weightUnitPreference.rawValue
        ])
    }
    
    func saveUserWeightUnitPreference(userId: String, weightUnitPreference: WeightUnitPreference) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedWeightUnitPreference.rawValue: weightUnitPreference.rawValue
        ])
    }

    func saveUserExerciseFrequency(userId: String, exerciseFrequency: ExerciseFrequency) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedExerciseFrequency.rawValue: exerciseFrequency.rawValue
        ])
    }

    func saveUserDailyActivityLevel(userId: String, activityLevel: ActivityLevel) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedDailyActivityLevel.rawValue: activityLevel.rawValue
        ])
    }

    func saveUserCardioFitnessLevel(userId: String, cardioFitnessLevel: CardioFitnessLevel) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedCardioFitnessLevel.rawValue: cardioFitnessLevel.rawValue
        ])
    }

    func saveUserCompleteAccountSetup(userId: String, input: CompleteAccountSetupProfileInput) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedDateOfBirth.rawValue: input.dateOfBirth,
            UserModel.CodingKeys.submittedGender.rawValue: input.gender,
            UserModel.CodingKeys.submittedHeightCentimeters.rawValue: input.heightCentimeters,
            UserModel.CodingKeys.submittedLengthUnitPreference.rawValue: input.lengthUnitPreference,
            UserModel.CodingKeys.submittedWeightKilograms.rawValue: input.weightKilograms,
            UserModel.CodingKeys.submittedWeightUnitPreference.rawValue: input.weightUnitPreference,
            UserModel.CodingKeys.submittedExerciseFrequency.rawValue: input.exerciseFrequency,
            UserModel.CodingKeys.submittedDailyActivityLevel.rawValue: input.dailyActivityLevel,
            UserModel.CodingKeys.submittedCardioFitnessLevel.rawValue: input.cardioFitnessLevel
        ])
    }

    func updateHealthConsents(userId: String, disclaimerVersion: String, privacyVersion: String, acceptedAt: Date) async throws {
        let data: [String: Any] = [
            "accepted_health_disclaimer_version": disclaimerVersion,
            "accepted_health_disclaimer_at": acceptedAt,
            "accepted_health_privacy_version": privacyVersion,
            "accepted_health_privacy_at": acceptedAt
        ]
        try await collection.document(userId).updateData(data)
    }

    func saveUserCurrentGoalId(userId: String, currentGoalId: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedCurrentGoalId.rawValue: currentGoalId
        ])
    }

    func saveUserFavouriteGymProfileId(userId: String, favouriteGymProfileId: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedFavouriteGymProfileId.rawValue: favouriteGymProfileId
        ])
    }

    func saveUserActiveTrainingProgramId(userId: String, activeTrainingProgramId: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedActiveTrainingProgramId.rawValue: activeTrainingProgramId
        ])
    }

    func updateDidCompleteOnboarding(userId: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true
        ])
    }
    
    func saveUserFCMToken(userId: String, token: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.fcmToken.rawValue: token
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

    // MARK: - User Streaming
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection.streamDocument(id: userId)
    }

    // MARK: - User deletion
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
        
    func saveUserLastSignInDate(userId: String) async throws {
        let lastSignInDate = Date()
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.lastSignInDate.rawValue: lastSignInDate
        ])
    }

}
