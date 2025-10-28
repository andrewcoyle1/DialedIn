//
//  UserManagerTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 28/10/2025.
//

import Testing
import Foundation

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
            lastSignInDate: Date(),
            isNewUser: true
        )
        
        try await manager.logIn(auth: authInfo, image: nil)
        
        // Verify current user is set
        #expect(manager.currentUser != nil)
        #expect(manager.currentUser?.userId == authInfo.uid)
        #expect(manager.currentUser?.email == authInfo.email)
        #expect(manager.currentUser?.onboardingStep == .subscription)
        #expect(manager.currentUser?.didCompleteOnboarding == false)
    }
    
    @Test("Test Login With Existing User Does Not Reset Onboarding")
    func testLoginWithExistingUserDoesNotResetOnboarding() async throws {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        let authInfo = UserAuthInfo(
            uid: String.random,
            email: "\(String.random)@example.com",
            isAnonymous: false,
            creationDate: Date(),
            lastSignInDate: Date(),
            isNewUser: false
        )
        
        try await manager.logIn(auth: authInfo, image: nil)
        
        // Verify current user is set
        #expect(manager.currentUser != nil)
        #expect(manager.currentUser?.userId == authInfo.uid)
        // For existing users, onboarding step should not be initialized
        #expect(manager.currentUser?.onboardingStep == nil)
        #expect(manager.currentUser?.didCompleteOnboarding == nil)
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
            isNewUser: true
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
        
        manager.logOut()
        
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
    
    // MARK: - Save Complete Account Setup Profile Tests
    
    @Test("Test Save Complete Account Setup Profile Updates User")
    func testSaveCompleteAccountSetupProfileUpdatesUser() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let dateOfBirth = Date.random
        let heightCm = 180.0
        let weightKg = 75.0
        
        let updatedUser = try await manager.saveCompleteAccountSetupProfile(
            dateOfBirth: dateOfBirth,
            gender: .male,
            heightCentimeters: heightCm,
            weightKilograms: weightKg,
            exerciseFrequency: .daily,
            dailyActivityLevel: .active,
            cardioFitnessLevel: .intermediate,
            lengthUnitPreference: .centimeters,
            weightUnitPreference: .kilograms
        )
        
        #expect(updatedUser.userId == mockUser.userId)
        #expect(updatedUser.dateOfBirth == dateOfBirth)
        #expect(updatedUser.gender == .male)
        #expect(updatedUser.heightCentimeters == heightCm)
        #expect(updatedUser.weightKilograms == weightKg)
        #expect(updatedUser.exerciseFrequency == .daily)
        #expect(updatedUser.dailyActivityLevel == .active)
        #expect(updatedUser.cardioFitnessLevel == .intermediate)
    }
    
    @Test("Test Save Complete Account Setup Profile Throws When No Current User")
    func testSaveCompleteAccountSetupProfileThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.saveCompleteAccountSetupProfile(
                dateOfBirth: Date(),
                gender: .male,
                heightCentimeters: 180.0,
                weightKilograms: 75.0,
                exerciseFrequency: .daily,
                dailyActivityLevel: .active,
                cardioFitnessLevel: .intermediate,
                lengthUnitPreference: .centimeters,
                weightUnitPreference: .kilograms
            )
        }
    }
    
    // MARK: - Mark Unanonymous Tests
    
    @Test("Test Mark Unanonymous Succeeds With Current User")
    func testMarkUnanonymousSucceedsWithCurrentUser() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        try await manager.markUnanonymous(email: "newemail@example.com")
        
        // No error should be thrown
    }
    
    @Test("Test Mark Unanonymous Throws When No Current User")
    func testMarkUnanonymousThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.markUnanonymous(email: "newemail@example.com")
        }
    }
    
    // MARK: - Update Personal Info Tests
    
    @Test("Test Update First Name Succeeds")
    func testUpdateFirstNameSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        try await manager.updateFirstName(firstName: "NewFirstName")
        
        // No error should be thrown
    }
    
    @Test("Test Update First Name Throws When No Current User")
    func testUpdateFirstNameThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.updateFirstName(firstName: "NewFirstName")
        }
    }
    
    @Test("Test Update Last Name Succeeds")
    func testUpdateLastNameSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        try await manager.updateLastName(lastName: "NewLastName")
        
        // No error should be thrown
    }
    
    @Test("Test Update Last Name Throws When No Current User")
    func testUpdateLastNameThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.updateLastName(lastName: "NewLastName")
        }
    }
    
    @Test("Test Update Date Of Birth Succeeds")
    func testUpdateDateOfBirthSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let newDob = Date.random
        try await manager.updateDateOfBirth(dob: newDob)
        
        // No error should be thrown
    }
    
    @Test("Test Update Date Of Birth Throws When No Current User")
    func testUpdateDateOfBirthThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.updateDateOfBirth(dob: Date())
        }
    }
    
    @Test("Test Update Gender Succeeds")
    func testUpdateGenderSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        try await manager.updateGender(gender: .female)
        
        // No error should be thrown
    }
    
    @Test("Test Update Gender Throws When No Current User")
    func testUpdateGenderThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.updateGender(gender: .female)
        }
    }
    
    // MARK: - Update Weight Tests
    
    @Test("Test Update Weight Succeeds And Updates Local Cache")
    func testUpdateWeightSucceedsAndUpdatesLocalCache() async throws {
        let mockUser = UserModel(
            userId: String.random,
            email: "\(String.random)@example.com",
            weightKilograms: 70.0
        )
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let newWeight = 75.0
        try await manager.updateWeight(userId: mockUser.userId, weightKg: newWeight)
        
        // Verify local cache was updated
        #expect(manager.currentUser?.weightKilograms == newWeight)
    }
    
    @Test("Test Update Weight Does Not Update Cache For Different User")
    func testUpdateWeightDoesNotUpdateCacheForDifferentUser() async throws {
        let mockUser = UserModel(
            userId: String.random,
            email: "\(String.random)@example.com",
            weightKilograms: 70.0
        )
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let differentUserId = String.random
        try await manager.updateWeight(userId: differentUserId, weightKg: 75.0)
        
        // Verify local cache was NOT updated
        #expect(manager.currentUser?.weightKilograms == 70.0)
    }
    
    // MARK: - Update Profile Image URL Tests
    
    @Test("Test Update Profile Image URL Succeeds")
    func testUpdateProfileImageURLSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        try await manager.updateProfileImageUrl(url: "https://example.com/image.jpg")
        
        // No error should be thrown
    }
    
    @Test("Test Update Profile Image URL Throws When No Current User")
    func testUpdateProfileImageURLThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.updateProfileImageUrl(url: "https://example.com/image.jpg")
        }
    }
    
    // MARK: - Update Metadata Tests
    
    @Test("Test Update Last Sign In Date Succeeds")
    func testUpdateLastSignInDateSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        try await manager.updateLastSignInDate()
        
        // No error should be thrown
    }
    
    @Test("Test Update Last Sign In Date Throws When No Current User")
    func testUpdateLastSignInDateThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.updateLastSignInDate()
        }
    }
    
    @Test("Test Update Onboarding Step Advances To New Step")
    func testUpdateOnboardingStepAdvancesToNewStep() async throws {
        let mockUser = UserModel.mockWithStep(.subscription)
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        try await manager.updateOnboardingStep(step: .completeAccountSetup)
        
        // Verify local cache was updated
        #expect(manager.currentUser?.onboardingStep == .completeAccountSetup)
    }
    
    @Test("Test Update Onboarding Step Does Not Go Backward")
    func testUpdateOnboardingStepDoesNotGoBackward() async throws {
        let mockUser = UserModel.mockWithStep(.goalSetting)
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        try await manager.updateOnboardingStep(step: .subscription)
        
        // Verify step did not change (monotonic guard)
        #expect(manager.currentUser?.onboardingStep == .goalSetting)
    }
    
    @Test("Test Update Onboarding Step To Complete Sets Did Complete Onboarding")
    func testUpdateOnboardingStepToCompleteSetsDidCompleteOnboarding() async throws {
        let mockUser = UserModel.mockWithStep(.customiseProgram)
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        try await manager.updateOnboardingStep(step: .complete)
        
        // Verify both step and completion flag are set
        #expect(manager.currentUser?.onboardingStep == .complete)
        #expect(manager.currentUser?.didCompleteOnboarding == true)
    }
    
    @Test("Test Update Onboarding Step Throws When No Current User")
    func testUpdateOnboardingStepThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.updateOnboardingStep(step: .complete)
        }
    }
    
    // MARK: - Goal Settings Tests
    
    @Test("Test Update Current Goal Id Succeeds")
    func testUpdateCurrentGoalIdSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let goalId = String.random
        try await manager.updateCurrentGoalId(goalId: goalId)
        
        // No error should be thrown
    }
    
    @Test("Test Update Current Goal Id Throws When No Current User")
    func testUpdateCurrentGoalIdThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.updateCurrentGoalId(goalId: "goal123")
        }
    }
    
    // MARK: - Consents Tests
    
    @Test("Test Update Health Consents Succeeds")
    func testUpdateHealthConsentsSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        try await manager.updateHealthConsents(
            disclaimerVersion: "1.0",
            privacyVersion: "2.0",
            acceptedAt: Date()
        )
        
        // No error should be thrown
    }
    
    @Test("Test Update Health Consents Throws When No Current User")
    func testUpdateHealthConsentsThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.updateHealthConsents(
                disclaimerVersion: "1.0",
                privacyVersion: "2.0",
                acceptedAt: Date()
            )
        }
    }
    
    // MARK: - User Blocking Tests
    
    @Test("Test Block User Succeeds")
    func testBlockUserSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let blockedUserId = String.random
        try await manager.blockUser(userId: blockedUserId)
        
        // No error should be thrown
    }
    
    @Test("Test Block User Throws When No Current User")
    func testBlockUserThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.blockUser(userId: "user123")
        }
    }
    
    @Test("Test Unblock User Succeeds")
    func testUnblockUserSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let unblockedUserId = String.random
        try await manager.unblockUser(userId: unblockedUserId)
        
        // No error should be thrown
    }
    
    @Test("Test Unblock User Throws When No Current User")
    func testUnblockUserThrowsWhenNoCurrentUser() async {
        let services = MockUserServices(user: nil)
        let manager = UserManager(services: services)
        
        await #expect(throws: UserManager.UserManagerError.self) {
            try await manager.unblockUser(userId: "user123")
        }
    }
    
    // MARK: - Error Handling Tests
    
    @Test("Test Remote Service Error Is Propagated")
    func testRemoteServiceErrorIsPropagated() async {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser, showError: true)
        let manager = UserManager(services: services)
        
        await #expect(throws: URLError.self) {
            try await manager.updateFirstName(firstName: "NewName")
        }
    }
    
    @Test("Test Save User Succeeds")
    func testSaveUserSucceeds() async throws {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser)
        let manager = UserManager(services: services)
        
        let newUser = UserModel(
            userId: String.random,
            email: "\(String.random)@example.com",
            firstName: "Test"
        )
        
        try await manager.saveUser(user: newUser, image: nil)
        
        // No error should be thrown
    }
    
    @Test("Test Save User With Error Throws")
    func testSaveUserWithErrorThrows() async {
        let mockUser = UserModel.mock
        let services = MockUserServices(user: mockUser, showError: true)
        let manager = UserManager(services: services)
        
        let newUser = UserModel(
            userId: String.random,
            email: "\(String.random)@example.com",
            firstName: "Test"
        )
        
        await #expect(throws: URLError.self) {
            try await manager.saveUser(user: newUser, image: nil)
        }
    }
    
    // MARK: - User Manager Error Tests
    
    @Test("Test User Manager Error Provides Localized Description")
    func testUserManagerErrorProvidesLocalizedDescription() {
        let error = UserManager.UserManagerError.noUserId
        
        // Verify it provides a localized description
        #expect(error.errorDescription == "No user id available")
    }
}
