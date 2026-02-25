//
//  RemoteUserService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/15/24.
//

import SwiftUI

@MainActor
protocol RemoteUserService: Sendable {
    func getUser(userId: String) async throws -> UserModel
    func saveUser(user: UserModel) async throws
    func saveUserName(userId: String, firstName: String?, lastName: String?) async throws
    func saveUserEmail(userId: String, email: String) async throws
    func saveUserProfileImage(userId: String, image: PlatformImage) async throws
    func saveUserLastSignInDate(userId: String) async throws
    func saveUserGender(userId: String, gender: Gender) async throws
    func saveUserDateOfBirth(userId: String, dateOfBirth: Date) async throws
    func saveUserHeightCentimeters(userId: String, heightInCentimeters: Double, lengthUnitPreference: LengthUnitPreference) async throws
    func saveUserLengthUnitPreference(userId: String, lengthUnitPreference: LengthUnitPreference) async throws
    func saveUserWeightKilograms(userId: String, weightInKilograms: Double, weightUnitPreference: WeightUnitPreference) async throws
    func saveUserWeightUnitPreference(userId: String, weightUnitPreference: WeightUnitPreference) async throws
    func saveUserExerciseFrequency(userId: String, exerciseFrequency: ExerciseFrequency) async throws
    func saveUserDailyActivityLevel(userId: String, activityLevel: ActivityLevel) async throws
    func saveUserCardioFitnessLevel(userId: String, cardioFitnessLevel: CardioFitnessLevel) async throws
    func saveUserCompleteAccountSetup(userId: String, input: CompleteAccountSetupProfileInput) async throws
    
    func updateHealthConsents(userId: String, disclaimerVersion: String, privacyVersion: String, acceptedAt: Date) async throws

    func saveUserCurrentGoalId(userId: String, currentGoalId: String) async throws
    
    func saveUserFavouriteGymProfileId(userId: String, favouriteGymProfileId: String) async throws

    func saveUserActiveTrainingProgramId(userId: String, activeTrainingProgramId: String) async throws

    func saveUserFCMToken(userId: String, token: String) async throws
    func blockUser(currentUserId: String, blockedUserId: String) async throws
    func unblockUser(currentUserId: String, blockedUserId: String) async throws
    func updateDidCompleteOnboarding(userId: String) async throws
    
    func deleteUser(userId: String) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
}
