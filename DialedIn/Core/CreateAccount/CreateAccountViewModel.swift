//
//  CreateAccountViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol CreateAccountInteractor {
    func trackEvent(event: LoggableEvent)
    func signInApple() async throws -> UserAuthInfo?
    func signInGoogle() async throws -> UserAuthInfo
    func logIn(auth: UserAuthInfo, image: PlatformImage?) async throws
}

extension CoreInteractor: CreateAccountInteractor { }

@Observable
@MainActor
class CreateAccountViewModel {
    private let interactor: CreateAccountInteractor

    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    init(
        interactor: CreateAccountInteractor
    ) {
        self.interactor = interactor
    }
    
    func onSignInApplePressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.appleAuthStart)
        Task {
            do {
                guard let result = try await interactor.signInApple() else {
                    return
                }
                interactor.trackEvent(event: Event.appleAuthSuccess(user: result))

                try await interactor.logIn(auth: result, image: nil)
                interactor.trackEvent(event: Event.appleAuthLoginSuccess(user: result))

                onDidSignIn?(result.isNewUser)
                onDismiss()
            } catch {
                interactor.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
    }
    
    func onSignInGooglePressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.googleAuthStart)
        Task {
            do {
                let result = try await interactor.signInGoogle()
                interactor.trackEvent(event: Event.googleAuthSuccess(user: result))

                try await interactor.logIn(auth: result, image: nil)
                interactor.trackEvent(event: Event.googleAuthLoginSuccess(user: result))

                onDidSignIn?(result.isNewUser)
                onDismiss()
            } catch {
                interactor.trackEvent(event: Event.googleAuthFail(error: error))
            }
        }
    }
    
    enum Event: LoggableEvent {
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfo)
        case appleAuthLoginSuccess(user: UserAuthInfo)
        case appleAuthFail(error: Error)
        case googleAuthStart
        case googleAuthSuccess(user: UserAuthInfo)
        case googleAuthLoginSuccess(user: UserAuthInfo)
        case googleAuthFail(error: Error)

        var eventName: String {
            switch self {
            case .appleAuthStart:           return "CreateAccountView_AppleAuth_Start"
            case .appleAuthSuccess:         return "CreateAccountView_AppleAuth_Success"
            case .appleAuthLoginSuccess:    return "CreateAccountView_AppleAuth_Login_Success"
            case .appleAuthFail:            return "CreateAccountView_AppleAuth_Fail"
            case .googleAuthStart:          return "CreateAccountView_GoogleAuth_Start"
            case .googleAuthSuccess:        return "CreateAccountView_GoogleAuth_Success"
            case .googleAuthLoginSuccess:   return "CreateAccountView_GoogleAuth_Login_Success"
            case .googleAuthFail:           return "CreateAccountView_GoogleAuth_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .appleAuthSuccess(user: let user),
                    .appleAuthLoginSuccess(user: let user),
                    .googleAuthSuccess(user: let user),
                    .googleAuthLoginSuccess(user: let user):
                var dict = user.eventParameters
                dict["is_new_user"] = user.isNewUser
                return dict
            case .appleAuthFail(error: let error), .googleAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .appleAuthFail, .googleAuthFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}
