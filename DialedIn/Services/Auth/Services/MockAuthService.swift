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
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        let user = UserAuthInfo.mock(isAnonymous: true)
        return (user, true)
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        let user = UserAuthInfo.mock(isAnonymous: false)
        return (user, false)
    }
    
    func signOut() throws {
        try tryShowError()
    }
    
    func deleteAccount() async throws {
        try await Task.sleep(for: .seconds(delay))
        try tryShowError()
    }
    
}
