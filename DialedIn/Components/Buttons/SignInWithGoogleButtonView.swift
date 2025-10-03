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
        HStack(spacing: 12) {
            Spacer()
            ZStack {
                Image(style == .light ? "GoogleLogoLight" : "GoogleLogoDark")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(Rectangle().inset(by: 10))
            }
            .frame(width: 20, height: 20)
            Text(scheme.description)
                .foregroundStyle(style.accentColour)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(style.backgroundColour)
        .cornerRadius(22)
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .shadow(color: style.accentColour, radius: 1)
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
            case .dark: return Color.black
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
