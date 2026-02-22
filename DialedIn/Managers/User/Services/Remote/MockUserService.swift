//
//  MockUserService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/15/24.
//

import SwiftUI

@MainActor
class MockUserService: RemoteUserService {
    
    @Published var currentUser: UserModel?
    let delay: Double
    let showError: Bool
    
    init(user: UserModel? = UserModel.mock, delay: Double = 0, showError: Bool = false) {
        self.currentUser = user
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func getUser(userId: String) async throws -> UserModel {
        guard let user = UserModel.mocks.first(where: { $0.userId == userId }) else {
            throw URLError(.badURL)
        }
        
        return user
    }
    
    func saveUser(user: UserModel) async throws {
        currentUser = user
    }
    
    func updateUserName(userId: String, firstName: String?, lastName: String?) async throws {
        
    }
    
    func saveUserEmail(userId: String, email: String) async throws {
        
    }
    
    func saveUserProfileImage(userId: String, image: PlatformImage) async throws {
        
    }
    
    func saveUserLastSignInDate(userId: String) async throws {
        
    }
    
    func saveUserGender(userId: String, gender: Gender) async throws {
        
    }
    
    func saveUserDateOfBirth(userId: String, dateOfBirth: Date) async throws {
        
    }
    
    func saveUserWeightKilograms(userId: String, weightKg: Double) async throws {
        
    }
    
    func saveUserExerciseFrequency(userId: String, exerciseFrequency: ProfileExerciseFrequency) async throws {
        
    }
    
    func saveUserDailyActivityLevel(userId: String, dailyActivityLevel: ProfileDailyActivityLevel) async throws {
        
    }
    
    func saveUserCardioFitnessLevel(userId: String, cardioFitnessLevel: ProfileCardioFitnessLevel) async throws {
        
    }
    
    func saveUserLengthUnitPreference(userId: String, lengthUnitPreference: LengthUnitPreference) async throws {
        
    }
    
    func saveUserWeightUnitPreference(userId: String, weightUnitPreference: WeightUnitPreference) async throws {
        
    }
    
    func saveUserCurrentGoalId(userId: String, currentGoalId: String) async throws {
        
    }
    
    func saveUserActiveTrainingProgramId(userId: String, activeTrainingProgramId: String) async throws {
        
    }
    
    func saveUserFavouriteGymProfileId(userId: String, favouriteGymProfileId: String) async throws {
        
    }
    
    func saveUserFCMToken(userId: String, token: String) async throws {
        
    }
    
    func blockUser(currentUserId: String, blockedUserId: String) async throws {
        
    }
    
    func unblockUser(currentUserId: String, blockedUserId: String) async throws {
        
    }
    
    func updateDidCompleteOnboarding(userId: String) async throws {

    }

    // swiftlint:disable:next function_parameter_count
    func updateUserAuthState(userId: String, isAnonymous: Bool, authProviders: [String], email: String?, displayName: String?, firstName: String?, lastName: String?, phoneNumber: String?, photoUrl: String?, lastSignInDate: Date?) async throws {

    }

    func deleteUser(userId: String) async throws {
        
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
            
            Task {
                for await value in $currentUser.values {
                    if let value {
                        continuation.yield(value)
                    }
                }
            }
        }
    }
    
    func updateHealthConsents(userId: String, disclaimerVersion: String, privacyVersion: String, acceptedAt: Date) async throws {

    }

}
