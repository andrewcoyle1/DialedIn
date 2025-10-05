//
//  FirebaseAuthService.swift
//  BrainBolt
//
//  Created by Andrew Coyle on 10/12/24.
//
@preconcurrency import FirebaseAuth
import SwiftUI
import SignInAppleAsync
import GoogleSignIn
import Firebase

struct FirebaseAuthService: AuthService {
    
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }
            
            onListenerAttached(listener)
        }
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }
        return nil
    }

    func createUser(email: String, password: String) async throws -> UserAuthInfo {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.asAuthInfo
    }
    
    func sendVerificationEmail(user: UserAuthInfo) async throws {
        guard let currentUser = Auth.auth().currentUser, currentUser.uid == user.uid else {
            throw AuthError.userNotFound
        }
        try await currentUser.sendEmailVerification()
    }
    
    func checkEmailVerification(user: UserAuthInfo) async throws -> Bool {
        guard let currentUser = Auth.auth().currentUser, currentUser.uid == user.uid else {
            throw AuthError.userNotFound
        }
        // Reload user to ensure latest verification status
        try await currentUser.reload()
        return currentUser.isEmailVerified
    }
    
    func signInUser(email: String, password: String) async throws -> UserAuthInfo {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.asAuthInfo
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }

        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }

    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }

        try await user.updatePassword(to: password)
    }

    func reauthenticate(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
    }

    func signInAnonymously() async throws -> UserAuthInfo {
        let result = try await Auth.auth().signInAnonymously()
        return result.asAuthInfo
    }
    
    @MainActor
    func signInApple() async throws -> UserAuthInfo {
        let helper = SignInWithAppleHelper()
        let response = try await helper.signIn()
        
        let credential = OAuthProvider.credential(
            providerID: FirebaseAuth.AuthProviderID.apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        
        if let user = Auth.auth().currentUser, user.isAnonymous {
            do {
                // Try to link to existing anonymous account
                let result = try await user.link(with: credential)
                return result.asAuthInfo
            } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                switch authError {
                case .providerAlreadyLinked, .credentialAlreadyInUse:
                    if let secondaryCredential = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                        let result = try await Auth.auth().signIn(with: secondaryCredential)
                        return result.asAuthInfo
                    }
                default:
                    break
                }
            }
        }
        
        // Otherwise sign in to new account
        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthInfo
    }

    @MainActor
    func signInGoogle() async throws -> UserAuthInfo {
        guard let presentingViewController = UIApplication.shared.windows.first?.rootViewController else {
            throw AuthError.userNotFound
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            throw AuthError.userNotFound
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        
        if let currentUser = Auth.auth().currentUser, currentUser.isAnonymous {
            do {
                // Try to link to existing anonymous account
                let authResult = try await currentUser.link(with: credential)
                return authResult.asAuthInfo
            } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                switch authError {
                case .providerAlreadyLinked, .credentialAlreadyInUse:
                    if let secondaryCredential = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                        let authResult = try await Auth.auth().signIn(with: secondaryCredential)
                        return authResult.asAuthInfo
                    }
                default:
                    break
                }
            }
        }
        
        // Otherwise sign in to new account
        let authResult = try await Auth.auth().signIn(with: credential)
        return authResult.asAuthInfo
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    @MainActor
    func reauthenticateWithApple() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        let helper = SignInWithAppleHelper()
        let response = try await helper.signIn()
        let credential = OAuthProvider.credential(
            providerID: FirebaseAuth.AuthProviderID.apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        try await user.reauthenticate(with: credential)
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        try await user.delete()
    }
    
    enum AuthError: LocalizedError {
        case userNotFound
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "Current authenticated user not found."
            }
        }
    }
    
}

extension AuthDataResult {
    
    var asAuthInfo: UserAuthInfo {
        let isNewUser = additionalUserInfo?.isNewUser ?? true
        let firebaseUser = user
        var resolvedEmail: String? = firebaseUser.email
        if resolvedEmail == nil, let profile = additionalUserInfo?.profile as? [String: Any] {
            if let email = profile["email"] as? String {
                resolvedEmail = email
            }
        }
        let authInfo = UserAuthInfo(
            uid: firebaseUser.uid,
            email: resolvedEmail,
            isAnonymous: firebaseUser.isAnonymous,
            creationDate: firebaseUser.metadata.creationDate,
            lastSignInDate: firebaseUser.metadata.lastSignInDate,
            isNewUser: isNewUser
        )
        return authInfo
    }
}
