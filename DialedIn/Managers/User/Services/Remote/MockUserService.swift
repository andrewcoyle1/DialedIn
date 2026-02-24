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
    
    init(user: UserModel? = nil, delay: Double = 0, showError: Bool = false) {
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
        if let currentUser, currentUser.userId == userId {
            return currentUser
        }
        guard let user = UserModel.mocks.first(where: { $0.userId == userId }) else {
            throw URLError(.badURL)
        }
        return user
    }
    
    func saveUser(user: UserModel) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))
        currentUser = user
    }
    
    func updateUserName(userId: String, firstName: String?, lastName: String?) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserEmail(userId: String, email: String) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserProfileImage(userId: String, image: PlatformImage) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserLastSignInDate(userId: String) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserGender(userId: String, gender: Gender) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserDateOfBirth(userId: String, dateOfBirth: Date) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserWeightKilograms(userId: String, weightKg: Double) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserExerciseFrequency(userId: String, exerciseFrequency: ExerciseFrequency) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserDailyActivityLevel(userId: String, dailyActivityLevel: ActivityLevel) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserCardioFitnessLevel(userId: String, cardioFitnessLevel: CardioFitnessLevel) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserLengthUnitPreference(userId: String, lengthUnitPreference: LengthUnitPreference) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserWeightUnitPreference(userId: String, weightUnitPreference: WeightUnitPreference) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserCurrentGoalId(userId: String, currentGoalId: String) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))
        currentUser?.submittedCurrentGoalId = currentGoalId
    }
    
    func saveUserActiveTrainingProgramId(userId: String, activeTrainingProgramId: String) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserFavouriteGymProfileId(userId: String, favouriteGymProfileId: String) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func saveUserFCMToken(userId: String, token: String) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func blockUser(currentUserId: String, blockedUserId: String) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func unblockUser(currentUserId: String, blockedUserId: String) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func updateDidCompleteOnboarding(userId: String) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }
    
    func markOnboardingCompleted(userId: String) async throws {
        guard var currentUser else {
            throw URLError(.unknown)
        }
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

        currentUser.markDidCompleteOnboarding()
        self.currentUser = currentUser
    }

    // swiftlint:disable:next function_parameter_count
    func updateUserAuthState(userId: String, isAnonymous: Bool, authProviders: [String], email: String?, displayName: String?, firstName: String?, lastName: String?, phoneNumber: String?, photoUrl: String?, lastSignInDate: Date?) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

    }

    func deleteUser(userId: String) async throws {
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))

        currentUser = nil
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
        try tryShowError()
        try? await Task.sleep(for: .seconds(delay))
        currentUser?.acceptedHealthDisclaimerVersion = disclaimerVersion
        currentUser?.acceptedHealthDisclaimerDate = acceptedAt
        currentUser?.acceptedHealthPrivacyPolicyVersion = privacyVersion
        currentUser?.acceptedHealthPrivacyPolicyDate = acceptedAt
    }

}
