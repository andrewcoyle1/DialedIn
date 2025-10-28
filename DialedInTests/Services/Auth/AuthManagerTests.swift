//
//  AuthManagerTests.swift
//  DialedInTests
//
//  Created by Andrew Coyle on 25/10/2025.
//

import Testing
import Foundation

struct AuthManagerTests {

    // MARK: - Initialization Tests
    
    @Test("Test Initialization With Mock Service")
    func testInitializationWithMockService() async {
        let mockAuthInfo = UserAuthInfo.mock()
        let mockService = MockAuthService(user: mockAuthInfo)
        let authManager = AuthManager(service: mockService)
        
        #expect(authManager.auth != nil)
        #expect(authManager.auth?.uid == mockAuthInfo.uid)
    }
    
    @Test("Test Initialization With Nil User")
    func testInitializationWithNilUser() async {
        let mockService = MockAuthService(user: nil)
        let authManager = AuthManager(service: mockService)
        
        #expect(authManager.auth == nil)
    }
    
    // MARK: - Get Auth ID Tests
    
    @Test("Test Get Auth ID When Signed In")
    func testGetAuthIdWhenSignedIn() async throws {
        let mockAuthInfo = UserAuthInfo.mock()
        let mockService = MockAuthService(user: mockAuthInfo)
        let authManager = AuthManager(service: mockService)
        
        let authId = try authManager.getAuthId()
        #expect(authId == mockAuthInfo.uid)
    }
    
    @Test("Test Get Auth ID When Not Signed In")
    func testGetAuthIdWhenNotSignedIn() async throws {
        let mockService = MockAuthService(user: nil)
        let authManager = AuthManager(service: mockService)
        
        #expect(throws: AuthError.notSignedIn) {
            try authManager.getAuthId()
        }
    }
    
    // MARK: - Email Authentication Tests
    
    @Test("Test Create User")
    func testCreateUser() async throws {
        let mockService = MockAuthService(user: nil)
        let authManager = AuthManager(service: mockService)
        
        let result = try await authManager.createUser(email: "test@example.com", password: "password123")
        
        #expect(result.uid == "mock_user_123")
        #expect(authManager.auth != nil)
        #expect(authManager.auth?.uid == result.uid)
    }
    
    @Test("Test Sign In User")
    func testSignInUser() async throws {
        let mockService = MockAuthService(user: nil)
        let authManager = AuthManager(service: mockService)
        
        let result = try await authManager.signInUser(email: "test@example.com", password: "password123")
        
        #expect(result.uid == "mock_user_123")
    }
    
    @Test("Test Reset Password")
    func testResetPassword() async throws {
        let mockService = MockAuthService(user: nil)
        let authManager = AuthManager(service: mockService)
        
        try await authManager.resetPassword(email: "test@example.com")
        
        // Should not throw
        #expect(true)
    }
    
    @Test("Test Update Email")
    func testUpdateEmail() async throws {
        let mockAuthInfo = UserAuthInfo.mock()
        let mockService = MockAuthService(user: mockAuthInfo)
        let authManager = AuthManager(service: mockService)
        
        try await authManager.updateEmail(email: "newemail@example.com")
        
        // Should not throw
        #expect(true)
    }
    
    @Test("Test Update Password")
    func testUpdatePassword() async throws {
        let mockAuthInfo = UserAuthInfo.mock()
        let mockService = MockAuthService(user: mockAuthInfo)
        let authManager = AuthManager(service: mockService)
        
        try await authManager.updatePassword(password: "newpassword123")
        
        // Should not throw
        #expect(true)
    }
    
    @Test("Test Reauthenticate")
    func testReauthenticate() async throws {
        let mockAuthInfo = UserAuthInfo.mock()
        let mockService = MockAuthService(user: mockAuthInfo)
        let authManager = AuthManager(service: mockService)
        
        try await authManager.reauthenticate(email: "test@example.com", password: "password123")
        
        // Should not throw
        #expect(true)
    }
    
    // MARK: - Email Verification Tests
    
    @Test("Test Send Verification Email")
    func testSendVerificationEmail() async throws {
        let mockAuthInfo = UserAuthInfo.mock()
        let mockService = MockAuthService(user: mockAuthInfo)
        let authManager = AuthManager(service: mockService)
        
        try await authManager.sendVerificationEmail()
        
        // Should not throw
        #expect(true)
    }
    
    @Test("Test Send Verification Email When Not Signed In")
    func testSendVerificationEmailWhenNotSignedIn() async throws {
        let mockService = MockAuthService(user: nil)
        let authManager = AuthManager(service: mockService)
        
        await #expect(throws: AuthError.notSignedIn) {
            try await authManager.sendVerificationEmail()
        }
    }
    
    @Test("Test Check Email Verification")
    func testCheckEmailVerification() async throws {
        let mockAuthInfo = UserAuthInfo.mock()
        let mockService = MockAuthService(user: mockAuthInfo, isEmailVerified: true)
        let authManager = AuthManager(service: mockService)
        
        let isVerified = try await authManager.checkEmailVerification()
        #expect(isVerified == true)
    }
    
    @Test("Test Check Email Verification When Not Verified")
    func testCheckEmailVerificationWhenNotVerified() async throws {
        let mockAuthInfo = UserAuthInfo.mock()
        let mockService = MockAuthService(user: mockAuthInfo, isEmailVerified: false)
        let authManager = AuthManager(service: mockService)
        
        let isVerified = try await authManager.checkEmailVerification()
        #expect(isVerified == false)
    }
    
    @Test("Test Check Email Verification When Not Signed In")
    func testCheckEmailVerificationWhenNotSignedIn() async throws {
        let mockService = MockAuthService(user: nil)
        let authManager = AuthManager(service: mockService)
        
        let isVerified = try await authManager.checkEmailVerification()
        #expect(isVerified == false)
    }
    
    // MARK: - Anonymous Authentication Tests
    
    @Test("Test Sign In Anonymously")
    func testSignInAnonymously() async throws {
        let mockService = MockAuthService(user: nil)
        let authManager = AuthManager(service: mockService)
        
        let result = try await authManager.signInAnonymously()
        
        #expect(result.isAnonymous == true)
        #expect(authManager.auth != nil)
        #expect(authManager.auth?.isAnonymous == true)
    }
    
    // MARK: - Apple Authentication Tests
    
    @Test("Test Sign In With Apple")
    func testSignInWithApple() async throws {
        let mockService = MockAuthService(user: nil)
        let authManager = AuthManager(service: mockService)
        
        let result = try await authManager.signInApple()
        
        #expect(result.uid == "mock_user_123")
        #expect(authManager.auth != nil)
        #expect(authManager.auth?.uid == result.uid)
    }
    
    @Test("Test Reauthenticate With Apple")
    func testReauthenticateWithApple() async throws {
        let mockAuthInfo = UserAuthInfo.mock()
        let mockService = MockAuthService(user: mockAuthInfo)
        let authManager = AuthManager(service: mockService)
        
        try await authManager.reauthenticateWithApple()
        
        // Should not throw
        #expect(true)
    }
    
    // MARK: - Google Authentication Tests
    
    @Test("Test Sign In With Google")
    func testSignInWithGoogle() async throws {
        let mockService = MockAuthService(user: nil)
        let authManager = AuthManager(service: mockService)
        
        let result = try await authManager.signInGoogle()
        
        #expect(result.uid == "mock_user_123")
        #expect(authManager.auth != nil)
        #expect(authManager.auth?.uid == result.uid)
    }
    
    // MARK: - Sign Out Tests
    
    @Test("Test Sign Out")
    func testSignOut() async throws {
        let mockAuthInfo = UserAuthInfo.mock()
        let mockService = MockAuthService(user: mockAuthInfo)
        let authManager = AuthManager(service: mockService)
        
        #expect(authManager.auth != nil)
        
        try authManager.signOut()
        
        #expect(authManager.auth == nil)
    }
    
    // MARK: - Delete Account Tests
    
    @Test("Test Delete Account")
    func testDeleteAccount() async throws {
        let mockAuthInfo = UserAuthInfo.mock()
        let mockService = MockAuthService(user: mockAuthInfo)
        let authManager = AuthManager(service: mockService)
        
        #expect(authManager.auth != nil)
        
        try await authManager.deleteAccount()
        
        #expect(authManager.auth == nil)
    }
    
    // MARK: - AuthError Tests
    
    @Test("Test AuthError Not Signed In")
    func testAuthErrorNotSignedIn() {
        let error = AuthError.notSignedIn
        
        #expect(error.localizedDescription == "User is not signed in")
    }
}
