//
//  MockAuthService.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/12/24.
//
import Foundation

struct MockAuthService: AuthService {
    
    let currentUser: UserAuthInfo?
    let delay: Double
    let showError: Bool
    
    init(user: UserAuthInfo? = nil, delay: Double = 0, showError: Bool = false) {
        self.currentUser = user
        self.delay = delay
        self.showError = showError
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
        print("User created")
        return UserAuthInfo.mock(isAnonymous: false)
    }

    @discardableResult
    func signInUser(email: String, password: String) async throws -> UserAuthInfo {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        print("User signed in")
        return UserAuthInfo.mock(isAnonymous: false)
    }

    func resetPassword(email: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        print("Password reset email sent")
    }

    func updateEmail(email: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        print("Email updated")
    }

    func updatePassword(password: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        print("Password updated")
    }

    func reauthenticate(email: String, password: String) async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        print("Reauthenticated")
    }

    func signInAnonymously() async throws -> UserAuthInfo {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        print("Signed in anonymously")
        return UserAuthInfo.mock(isAnonymous: true)
    }
    
    func signInApple() async throws -> UserAuthInfo {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        print("Signed in with Apple")
        return UserAuthInfo.mock(isAnonymous: false)
    }

    func signInGoogle() async throws -> UserAuthInfo {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        print("Signed in with Google")
        return UserAuthInfo.mock(isAnonymous: false)
    }

    func reauthenticateWithApple() async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        print("Reauthenticated with Apple")

    }
    
    func signOut() throws {
        try tryShowError()
        print("Signed out")

    }
    
    func deleteAccount() async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        print("Deleted Account")

    }
    
}
