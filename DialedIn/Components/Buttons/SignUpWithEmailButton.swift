//
//  SignInWithEmailButton.swift
//  DialedIn
//
//  Created by Andrew Coyle on 03/10/2025.
//

import SwiftUI

struct SignUpWithEmailButton: View {

    var action: () -> Void

    var body: some View {
        Capsule()
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.ultraThinMaterial)
            .padding(.horizontal)
            .overlay(alignment: .center) {
                Text("Sign Up with Email")
                    .fontWeight(.medium)
                    .font(.system(size: 21))
            }
            .anyButton(.press) {
                action()
            }
    }
}

#Preview {
    SignUpWithEmailButton {
        print("Sign up with email pressed")
    }
}
