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

    // MARK: - Current User

    @Test("Test Current User Comes From The Sync Engine")
    func testCurrentUserComesFromTheSyncEngine() async throws {
        // Captured once: `UserModel.mock` is computed, and builds its dates from `Date()`, so two
        // reads of it are never equal.
        let mockUser = UserModel.mock
        let manager = TestManagers.userManager(user: mockUser)

        try await manager.signIn(auth: auth(uid: mockUser.userId), isNewUser: false)

        await TestManagers.eventually { manager.currentUser != nil }
        #expect(manager.currentUser == mockUser)
    }

    @Test("Test Current User Is Nil Before Signing In")
    func testCurrentUserIsNilBeforeSigningIn() async {
        let manager = TestManagers.userManager(user: UserModel.mock)

        // The engine only holds a document once it is listening, so a manager that has not signed
        // in has no user, whatever the remote holds.
        #expect(manager.currentUser == nil)
    }

    @Test("Test Current User Is Nil When The Remote Has No Document")
    func testCurrentUserIsNilWhenTheRemoteHasNoDocument() async throws {
        let manager = TestManagers.userManager(user: nil)

        try await manager.signIn(auth: auth(), isNewUser: false)

        #expect(manager.currentUser == nil)
    }

    // MARK: - Sign in

    @Test("Test Signing In As A New User Creates Their Document")
    func testSigningInAsANewUserCreatesTheirDocument() async throws {
        let manager = TestManagers.userManager(user: nil)
        let authInfo = auth(email: "\(String.random)@example.com")

        try await manager.signIn(auth: authInfo, isNewUser: true)

        await TestManagers.eventually { manager.currentUser != nil }
        let user = try #require(manager.currentUser)
        #expect(user.userId == authInfo.uid)
        #expect(user.email == authInfo.email)
        #expect(user.didCompleteOnboarding == false)
    }

    /// A returning user's stored profile is what counts: signing in must not write a fresh document
    /// over it and send them back through onboarding.
    @Test("Test Signing In As An Existing User Keeps Their Profile")
    func testSigningInAsAnExistingUserKeepsTheirProfile() async throws {
        let existingUser = UserModel.mockExisting
        let manager = TestManagers.userManager(user: existingUser)

        try await manager.signIn(auth: auth(uid: existingUser.userId), isNewUser: false)

        await TestManagers.eventually { manager.currentUser != nil }
        let user = try #require(manager.currentUser)
        #expect(user.userId == existingUser.userId)
        #expect(user.didCompleteOnboarding == true)
        #expect(user.inferredOnboardingStep == OnboardingStep.complete)
    }

    @Test("Test Signing In Anonymously Keeps No Email")
    func testSigningInAnonymouslyKeepsNoEmail() async throws {
        let manager = TestManagers.userManager(user: nil)

        try await manager.signIn(auth: auth(email: nil, isAnonymous: true), isNewUser: true)

        await TestManagers.eventually { manager.currentUser != nil }
        let user = try #require(manager.currentUser)
        #expect(user.isAnonymous == true)
        #expect(user.email == nil)
    }

    // MARK: - Sign out

    @Test("Test Signing Out Clears The Current User")
    func testSigningOutClearsTheCurrentUser() async throws {
        let mockUser = UserModel.mock
        let manager = TestManagers.userManager(user: mockUser)
        try await manager.signIn(auth: auth(uid: mockUser.userId), isNewUser: false)
        await TestManagers.eventually { manager.currentUser != nil }
        #expect(manager.currentUser != nil)

        manager.signOut()

        #expect(manager.currentUser == nil)
    }

    // MARK: - Following

    @Test("Test Following Users Are Empty Until Refreshed")
    func testFollowingUsersAreEmptyUntilRefreshed() async {
        let manager = TestManagers.userManager(user: UserModel.mock, following: UserModel.mocks)

        #expect(manager.followingUsers.isEmpty)
    }

    // MARK: - Blocking

    /// Blocking someone the reader follows takes the follow back in the same write, so a blocked
    /// person's sessions stop syncing into the feed.
    @Test("Test Blocking A Followed User Unfollows Them")
    func testBlockingAFollowedUserUnfollowsThem() async throws {
        let reader = UserModel(userId: "me", followingIds: ["friend", "other"])
        let manager = try await TestManagers.signedInUserManager(reader)

        try await manager.blockUser(userId: "friend")

        await TestManagers.eventually { manager.currentUser?.blockedUserIds == ["friend"] }
        #expect(manager.currentUser?.blockedUserIds == ["friend"])
        #expect(manager.currentUser?.followingIds == ["other"])
    }

    @Test("Test Unblocking Does Not Restore The Follow")
    func testUnblockingDoesNotRestoreTheFollow() async throws {
        let reader = UserModel(userId: "me", blockedUserIds: ["friend"], followingIds: ["other"])
        let manager = try await TestManagers.signedInUserManager(reader)

        try await manager.unblockUser(userId: "friend")

        await TestManagers.eventually { manager.currentUser?.blockedUserIds?.isEmpty == true }
        #expect(manager.currentUser?.blockedUserIds == [])
        #expect(manager.currentUser?.followingIds == ["other"])
    }

    // MARK: - Helpers

    private func auth(
        uid: String = String.random,
        email: String? = "\(String.random)@example.com",
        isAnonymous: Bool = false
    ) -> UserAuthInfo {
        UserAuthInfo(
            uid: uid,
            email: email,
            isAnonymous: isAnonymous,
            creationDate: Date(),
            lastSignInDate: Date()
        )
    }
}
