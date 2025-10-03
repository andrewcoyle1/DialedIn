//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/9/24.
//

import SwiftUI
import AuthenticationServices

struct CreateAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(LogManager.self) private var logManager
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager

    var title: String = "Create Account?"
    var subtitle: String = "Don't lose your data! Connect to an SSO provider to save your account."
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 28
            )
            .frame(height: 56)
            .anyButton(.press) {
                onSignInApplePressed()
            }
            
            Image("GoogleContinueButtonLight")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 56)
                .anyButton(.press) {
                    onSignInGooglePressed()
                }
            
            Spacer()
        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountView")
    }
    
    enum Event: LoggableEvent {
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthFail(error: Error)
        case googleAuthStart
        case googleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case googleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
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
            case .appleAuthSuccess(user: let user, isNewUser: let isNewUser),
                    .appleAuthLoginSuccess(user: let user, isNewUser: let isNewUser),
                    .googleAuthSuccess(user: let user, isNewUser: let isNewUser),
                    .googleAuthLoginSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParameters
                dict["is_new_user"] = isNewUser
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
    
    func onSignInApplePressed() {
        logManager.trackEvent(event: Event.appleAuthStart)
        Task {
            do {
                let result = try await authManager.signInApple()
                logManager.trackEvent(event: Event.appleAuthSuccess(user: result.user, isNewUser: result.isNewUser))

                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                logManager.trackEvent(event: Event.appleAuthLoginSuccess(user: result.user, isNewUser: result.isNewUser))

                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
    }
    
    func onSignInGooglePressed() {
        logManager.trackEvent(event: Event.googleAuthStart)
        Task {
            do {
                let result = try await authManager.signInGoogle()
                logManager.trackEvent(event: Event.googleAuthSuccess(user: result.user, isNewUser: result.isNewUser))

                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                logManager.trackEvent(event: Event.googleAuthLoginSuccess(user: result.user, isNewUser: result.isNewUser))

                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.googleAuthFail(error: error))
            }
        }
    }
}

#Preview {
    CreateAccountView()
        .previewEnvironment()
}
