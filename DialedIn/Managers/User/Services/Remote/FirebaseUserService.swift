//
//  FirebaseUserService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/15/24.
//

import FirebaseFirestore
import SwiftfulFirestore

typealias ListenerRegistration = FirebaseFirestore.ListenerRegistration

struct AnyListener: @unchecked Sendable {
    let listener: ListenerRegistration
}

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
    
    func updateUserName(userId: String, firstName: String? = nil, lastName: String? = nil) async throws {
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
    
    func saveUserLastSignInDate(userId: String) async throws {
        let lastSignInDate = Date()
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.lastSignInDate.rawValue: lastSignInDate
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
    
    func saveUserWeightKilograms(userId: String, weightKg: Double) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedWeightKilograms.rawValue: weightKg
        ])
    }

    func saveUserExerciseFrequency(userId: String, exerciseFrequency: ProfileExerciseFrequency) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedExerciseFrequency.rawValue: exerciseFrequency.rawValue
        ])
    }

    func saveUserDailyActivityLevel(userId: String, dailyActivityLevel: ProfileDailyActivityLevel) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedDailyActivityLevel.rawValue: dailyActivityLevel.rawValue
        ])
    }

    func saveUserCardioFitnessLevel(userId: String, cardioFitnessLevel: ProfileCardioFitnessLevel) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedCardioFitnessLevel.rawValue: cardioFitnessLevel.rawValue
        ])
    }

    func saveUserLengthUnitPreference(userId: String, lengthUnitPreference: LengthUnitPreference) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedLengthUnitPreference.rawValue: lengthUnitPreference.rawValue
        ])
    }

    func saveUserWeightUnitPreference(userId: String, weightUnitPreference: WeightUnitPreference) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedWeightUnitPreference.rawValue: weightUnitPreference.rawValue
        ])
    }

    func saveUserCurrentGoalId(userId: String, currentGoalId: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedCurrentGoalId.rawValue: currentGoalId
        ])
    }

    func saveUserActiveTrainingProgramId(userId: String, activeTrainingProgramId: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedActiveTrainingProgramId.rawValue: activeTrainingProgramId
        ])
    }

    func saveUserFavouriteGymProfileId(userId: String, favouriteGymProfileId: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.submittedFavouriteGymProfileId.rawValue: favouriteGymProfileId
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
    
    func updateDidCompleteOnboarding(userId: String) async throws {
        try await collection.updateDocument(id: userId, dict: [
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true
        ])
    }

    // swiftlint:disable:next function_parameter_count
    func updateUserAuthState(userId: String, isAnonymous: Bool, authProviders: [String], email: String?, displayName: String?, firstName: String?, lastName: String?, phoneNumber: String?, photoUrl: String?, lastSignInDate: Date?) async throws {
        var data: [String: Any] = [
            UserModel.CodingKeys.isAnonymous.rawValue: isAnonymous,
            UserModel.CodingKeys.authProviders.rawValue: authProviders
        ]
        if let email { data[UserModel.CodingKeys.email.rawValue] = email }
        if let displayName { data[UserModel.CodingKeys.displayName.rawValue] = displayName }
        if let firstName { data[UserModel.CodingKeys.firstName.rawValue] = firstName }
        if let lastName { data[UserModel.CodingKeys.lastName.rawValue] = lastName }
        if let phoneNumber { data[UserModel.CodingKeys.phoneNumber.rawValue] = phoneNumber }
        if let photoUrl { data[UserModel.CodingKeys.photoUrl.rawValue] = photoUrl }
        if let lastSignInDate { data[UserModel.CodingKeys.lastSignInDate.rawValue] = lastSignInDate }
        try await collection.document(userId).updateData(data)
    }

    // MARK: - User deletion
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
    
    // MARK: - User Streaming
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
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
