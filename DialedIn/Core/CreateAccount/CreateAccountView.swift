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
            Spacer()

            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 28
            )
            .anyButton(.press) {
                onSignInApplePressed()
            }
            .frame(height: 56)
            .frame(maxWidth: 320)
            
            SignInWithGoogleButtonView(style: .light, scheme: .signUpWithGoogle) {
                onSignInGooglePressed()
            }
            .frame(height: 56)
            .frame(maxWidth: 350)

        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountView")
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
    
    func onSignInApplePressed() {
        logManager.trackEvent(event: Event.appleAuthStart)
        Task {
            do {
                let result = try await authManager.signInApple()
                logManager.trackEvent(event: Event.appleAuthSuccess(user: result))

                try await userManager.logIn(auth: result)
                logManager.trackEvent(event: Event.appleAuthLoginSuccess(user: result))

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
                logManager.trackEvent(event: Event.googleAuthSuccess(user: result))

                try await userManager.logIn(auth: result)
                logManager.trackEvent(event: Event.googleAuthLoginSuccess(user: result))

                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.googleAuthFail(error: error))
            }
        }
    }
}

#Preview {
    NavigationStack {
        Text("Hello")
            .sheet(isPresented: Binding.constant(true)) {
                CreateAccountView()
            }
            .presentationDetents([.fraction(0.25)])
    }
    .previewEnvironment()
}
