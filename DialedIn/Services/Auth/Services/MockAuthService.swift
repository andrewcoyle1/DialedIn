//
//  MockAuthService.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/12/24.
//
import Foundation

struct MockAuthService: AuthService {
    
    let currentUser: UserAuthInfo?
    let delay: Double
    let showError: Bool
    let isEmailVerified: Bool
    
    init(user: UserAuthInfo? = nil, delay: Double = 0, showError: Bool = false, isEmailVerified: Bool = true) {
        self.currentUser = user
        self.delay = delay
        self.showError = showError
        self.isEmailVerified = isEmailVerified
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
        }
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        currentUser
    }

    func createUser(email: String, password: String) async throws -> UserAuthInfo {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return UserAuthInfo.mock(isAnonymous: false)
    }

    func sendVerificationEmail(user: UserAuthInfo) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func checkEmailVerification(user: UserAuthInfo) async throws -> Bool {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return isEmailVerified
    }

    @discardableResult
    func signInUser(email: String, password: String) async throws -> UserAuthInfo {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return UserAuthInfo.mock(isAnonymous: false)
    }

    func resetPassword(email: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }

    func updateEmail(email: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }

    func updatePassword(password: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }

    func reauthenticate(email: String, password: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }

    func signInAnonymously() async throws -> UserAuthInfo {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return UserAuthInfo.mock(isAnonymous: true)
    }
    
    func signInApple() async throws -> UserAuthInfo {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return UserAuthInfo.mock(isAnonymous: false)
    }

    func signInGoogle() async throws -> UserAuthInfo {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return UserAuthInfo.mock(isAnonymous: false)
    }

    func reauthenticateWithApple() async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
    func signOut() throws {
        try tryShowError()
    }
    
    func deleteAccount() async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
}
