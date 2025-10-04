//
//  SignInWithGoogleButton.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI

struct SignInWithGoogleButtonView: View {

    let style: DisplayMode
    let scheme: DisplayScheme
    let action: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Spacer()
            ZStack {
                Image(style == .light ? "GoogleLogoLight" : "GoogleLogoDark")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .clipShape(Rectangle().inset(by: 7.5))
            }
            .frame(width: 20, height: 20)
            Text(scheme.description)
                .foregroundStyle(style.accentColour)
                .fontWeight(.medium)
                .font(.system(size: 21))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 50)
        .background(style.backgroundColour)
        .cornerRadius(25)
        .frame(maxWidth: .infinity)
        .shadow(color: style.accentColour, radius: 1)
        .padding(.horizontal)
        .anyButton(.press) {
            action()
        }
    }

    enum DisplayMode {
        case light
        case dark

        var backgroundColour: Color {
            switch self {
            case .light: return Color.white
            case .dark: return Color(red: 19/255, green: 19/255, blue: 20/255)
            }
        }

        var accentColour: Color {
            switch self {
            case .light: return Color.black
            case .dark: return Color.white
            }
        }
    }

    enum DisplayScheme {
        case signUpWithGoogle
        case signInWithGoogle
        case continueWithGoogle

        var description: String {
            switch self {
            case .signInWithGoogle: return "Sign In with Google"
            case .signUpWithGoogle: return "Sign Up with Google"
            case .continueWithGoogle: return "Continue with Google"
            }
        }
    }
}

#Preview("Light - Sign In") {
    ZStack {
        Color.white.ignoresSafeArea()
        SignInWithGoogleButtonView(style: .light, scheme: .signInWithGoogle) {
            print("Text")
        }
    }
}

#Preview("Dark - Sign Up") {
    ZStack {
        Color.black.ignoresSafeArea()
        SignInWithGoogleButtonView(style: .dark, scheme: .signUpWithGoogle) {
            print("Text")
        }
    }
}

#Preview("Dark - Continue") {
    ZStack {
        Color.black.ignoresSafeArea()
        SignInWithGoogleButtonView(style: .dark, scheme: .continueWithGoogle) {
            print("Text")
        }
    }
}
