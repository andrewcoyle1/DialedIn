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
                    logManager?.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
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
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await service.signInAnonymously()
        // Immediately update auth state for UI responsiveness
        self.auth = result.user
        return result
    }
    
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await service.signInApple()
        // Immediately update auth state for UI responsiveness
        self.auth = result.user
        return result
    }
    
    func signOut() throws {
        logManager?.trackEvent(event: Event.signOutStart)
        
        try service.signOut()
        auth = nil
        logManager?.trackEvent(event: Event.signOutSuccess)
        
    }
    
    func reauthenticateWithApple() async throws {
        try await service.reauthenticateWithApple()
    }
    
    func deleteAccount() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        
        try await service.deleteAccount()
        auth = nil
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
        
    }
    
    enum AuthError: LocalizedError {
        case notSignedIn
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
