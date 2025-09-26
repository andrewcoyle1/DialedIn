//
//  MockUserService.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/15/24.
//

import SwiftUI

struct MockUserService: RemoteUserService {
    let currentUser: UserModel?
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
    
    func saveUser(user: UserModel, image: PlatformImage? = nil) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func markUnanonymous(userId: String, email: String? = nil) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
        
    func updateFirstName(userId: String, firstName: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func updateLastName(userId: String, lastName: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func updateDateOfBirth(userId: String, dateOfBirth: Date) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func updateGender(userId: String, gender: Gender) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func updateProfileImageUrl(userId: String, url: String?) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func updateLastSignInDate(userId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func markOnboardingCompleted(userId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func addCreatedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeCreatedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func addBookmarkedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeBookmarkedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func addFavouritedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeFavouritedExerciseTemplate(userId: String, exerciseTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func addCreatedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeCreatedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func addBookmarkedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeBookmarkedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func addFavouritedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func removeFavouritedWorkoutTemplate(userId: String, workoutTemplateId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func blockUser(currentUserId: String, blockedUserId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func unblockUser(currentUserId: String, blockedUserId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func deleteUser(userId: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func streamUser(userId: String, onListenerConfigured: @escaping (@escaping () -> Void) -> Void) -> AsyncThrowingStream<UserModel, Error> {
        onListenerConfigured({ /* no-op removal */ })
        return AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
        }
    }
    
}
