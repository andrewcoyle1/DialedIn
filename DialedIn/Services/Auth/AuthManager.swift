//
//  AuthM.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/13/24.
//
import SwiftUI
import SwiftfulUtilities

@MainActor
@Observable
class AuthManager {
    
    private let service: AuthService
    private(set) var auth: UserAuthInfo?
    private var listener: (any NSObjectProtocol)?
    private var logManager: LogManager?
    
    init(service: AuthService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.auth = service.getAuthenticatedUser()
        self.addAuthListener()
    }
    
    private func addAuthListener() {
        logManager?.trackEvent(event: Event.authListenerStart)
        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { listener in
                self.listener = listener
            }) {
                self.auth = value
                logManager?.trackEvent(event: Event.authListenerSuccess(user: value))
                
                if let value {
                    
                    logManager?.identifyUser(userId: value.uid, name: nil, email: value.email)
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    logManager?.addUserProperties(dict: SwiftfulUtilities.Utilities.eventParameters, isHighPriority: false)
                }
            }
        }
    }
    
    func getAuthId() throws -> String {
        guard let uid = auth?.uid else {
            throw AuthError.notSignedIn
        }
        return uid
    }

    // Email Authentication
    @discardableResult
    func createUser(email: String, password: String) async throws -> UserAuthInfo {
        let result = try await service.createUser(email: email, password: password)
        self.auth = result
        return result
    }

    func sendVerificationEmail() async throws {
        guard let auth else { throw AuthError.notSignedIn }
        try await service.sendVerificationEmail(user: auth)
    }

    func checkEmailVerification() async throws -> Bool {
        guard let auth else { return false }
        return try await service.checkEmailVerification(user: auth)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> UserAuthInfo {
        let result = try await service.signInUser(email: email, password: password)
        return result
    }

    func resetPassword(email: String) async throws {
        try await service.resetPassword(email: email)
    }

    func updateEmail(email: String) async throws {
        try await service.updateEmail(email: email)
    }

    func updatePassword(password: String) async throws {
        try await service.updatePassword(password: password)
    }

    func reauthenticate(email: String, password: String) async throws {
        try await service.reauthenticate(email: email, password: password)
    }

    // Anonymous Authentication
    @discardableResult
    func signInAnonymously() async throws -> UserAuthInfo {
        let result = try await service.signInAnonymously()
        // Immediately update auth state for UI responsiveness
        self.auth = result
        return result
    }

    // Sign in with Apple
    @discardableResult
    func signInApple() async throws -> UserAuthInfo {
        let result = try await service.signInApple()
        // Immediately update auth state for UI responsiveness
        self.auth = result
        return result
    }
    
    func reauthenticateWithApple() async throws {
        try await service.reauthenticateWithApple()
    }

    // Sign in with Google
    @discardableResult
    func signInGoogle() async throws -> UserAuthInfo {
        let result = try await service.signInGoogle()
        // Immediately update auth state for UI responsiveness
        self.auth = result
        return result
    }

    // Sign Out
    func signOut() throws {
        logManager?.trackEvent(event: Event.signOutStart)
        
        try service.signOut()
        auth = nil
        logManager?.trackEvent(event: Event.signOutSuccess)
        
    }
    
    // Delete Account
    func deleteAccount() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        
        try await service.deleteAccount()
        auth = nil
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
        
    }
    
    enum Event: LoggableEvent {
        case authListenerStart
        case authListenerSuccess(user: UserAuthInfo?)
        case signOutStart
        case signOutSuccess
        case deleteAccountStart
        case deleteAccountSuccess

        var eventName: String {
            switch self {
            case .authListenerStart:    return "AuthMan_AuthListener_Start"
            case .authListenerSuccess:  return "AuthMan_AuthListener_Success"
            case .signOutStart:         return "AuthMan_SignOut_Start"
            case .signOutSuccess:       return "AuthMan_SignOut_Success"
            case .deleteAccountStart:   return "AuthMan_DeleteAccount_Start"
            case .deleteAccountSuccess: return "AuthMan_DeleteAccount_Success"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .authListenerSuccess(user: let user):
                return user?.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
                
            }
        }
    }
}

enum AuthError: LocalizedError {
    case notSignedIn
}
