//
//  UserManagerTests.swift
//  DialedInUnitTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation
@testable import DialedIn

@MainActor
struct UserManagerTests {
    
    // MARK: - Initialization Tests
    
    @Test("Test Initialization With Existing User In Local Storage")
    func testInitializationWithExistingUser() async {
        let existingUser = UserModel.mock
        let services = MockUserServices(user: existingUser)
        let manager = UserManager(services: services)
        
        #expect(manager.currentUser == existingUser)
    }
    
    @Test("Test Initialization With No User In Local Storage")
    func testInitializationWithNoUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        #expect(manager.currentUser == nil)
    }
    
    // MARK: - Current User ID Tests
    
    @Test("Test Current User Id Returns User Id When User Exists")
    func testCurrentUserIdReturnsUserIdWhenUserExists() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let userId = try manager.currentUserId()
        
        #expect(userId == mockUser.userId)
    }
    
    @Test("Test Current User Id Throws Error When No User Exists")
    func testCurrentUserIdThrowsErrorWhenNoUserExists() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        #expect(throws: UserManager.UserManagerError.self) {
            try manager.currentUserId()
        }
    }
    
    // MARK: - Login Tests
    
    @Test("Test Login With New User Creates User With Onboarding Step")
    func testLoginWithNewUserCreatesUserWithOnboardingStep() async throws {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        let authInfo = UserAuthInfo(
            uid: String.random,
            email: "\(String.random)@example.com",
            isAnonymous: false,
            creationDate: Date(),
            lastSignInDate: Date()
        )
        
        try await manager.logIn(auth: authInfo, image: nil)
        
        // Verify current user is set
        #expect(manager.currentUser != nil)
        #expect(manager.currentUser?.userId == authInfo.uid)
        #expect(manager.currentUser?.email == authInfo.email)
        #expect(manager.currentUser?.inferredOnboardingStep == .subscription)
        #expect(manager.currentUser?.didCompleteOnboarding == false)
    }
    
    @Test("Test Login With Existing User Does Not Reset Onboarding")
    func testLoginWithExistingUserDoesNotResetOnboarding() async throws {
        let userId = String.random
        let email = "\(String.random)@example.com"
        
        // Create an existing user with no onboarding step set (as it would be for an existing user)
        let existingUser = UserModel.mockExisting
        
        let services = MockUserServices(user: existingUser)
        let manager = UserManager(services: services)
        
        let authInfo = UserAuthInfo(
            uid: userId,
            email: email,
            isAnonymous: false,
            creationDate: Date(),
            lastSignInDate: Date()
        )
        
        try await manager.logIn(auth: authInfo, image: nil)
        
        // Give the async stream a moment to process (stream finishes after yielding in mock)
        try await Task.sleep(for: .milliseconds(50))
        
        // Verify current user is set from the stream
        #expect(manager.currentUser != nil)
        #expect(manager.currentUser?.userId == authInfo.uid)
        // For existing users, onboarding step should not be initialized
        #expect(manager.currentUser?.inferredOnboardingStep == OnboardingStep.complete)
        #expect(manager.currentUser?.didCompleteOnboarding == true)
    }
    
    @Test("Test Login With Anonymous User")
    func testLoginWithAnonymousUser() async throws {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        let authInfo = UserAuthInfo(
            uid: String.random,
            email: nil,
            isAnonymous: true,
            creationDate: Date(),
            lastSignInDate: Date(),
        )
        
        try await manager.logIn(auth: authInfo, image: nil)
        
        #expect(manager.currentUser != nil)
        #expect(manager.currentUser?.isAnonymous == true)
        #expect(manager.currentUser?.email == nil)
    }
    
    // MARK: - Logout Tests
    
    @Test("Test Logout Clears Current User")
    func testLogoutClearsCurrentUser() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        #expect(manager.currentUser != nil)
        
        manager.signOut()
        
        #expect(manager.currentUser == nil)
    }
    
    // MARK: - Clear All Local Data Tests
    
    @Test("Test Clear All Local Data Removes Current User")
    func testClearAllLocalDataRemovesCurrentUser() async {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        #expect(manager.currentUser != nil)
        
        manager.clearAllLocalData()
        
        #expect(manager.currentUser == nil)
    }
    
    // MARK: - Mark Unanonymous Tests
    
    @Test("Test Mark Unanonymous Succeeds With Current User")
    func testMarkUnanonymousSucceedsWithCurrentUser() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        try await manager.remote.markOnboardingCompleted(userId: mockUser.userId)
        
        // No error should be thrown
    }
    
}
