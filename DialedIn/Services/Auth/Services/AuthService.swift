//
//  AuthService.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/12/24.
//
import SwiftUI

protocol AuthService: Sendable {
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?>
    func getAuthenticatedUser() -> UserAuthInfo?
    func createUser(email: String, password: String) async throws -> UserAuthInfo
    func signInUser(email: String, password: String) async throws -> UserAuthInfo
    func resetPassword(email: String) async throws
    func updateEmail(email: String) async throws
    func updatePassword(password: String) async throws
    func reauthenticate(email: String, password: String) async throws
    func signInAnonymously() async throws -> UserAuthInfo
    func signInApple() async throws -> UserAuthInfo
    func signInGoogle() async throws -> UserAuthInfo
    /// Reauthenticate the current user with Apple before sensitive operations
    func reauthenticateWithApple() async throws
    func signOut() throws
    func deleteAccount() async throws
}
