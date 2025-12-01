//
//  CreateAccountView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/9/24.
//

import SwiftUI
import CustomRouting

struct CreateAccountView: View {
    
    @State var presenter: CreateAccountPresenter

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(presenter.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(presenter.subtitle)
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
                presenter.onSignInApplePressed()
            }
            .frame(height: 56)
            .frame(maxWidth: 320)
            
            SignInWithGoogleButtonView(style: .light, scheme: .signUpWithGoogle) {
                presenter.onSignInGooglePressed()
            }
            .frame(height: 56)
            .frame(maxWidth: 350)

        }
        .padding(16)
        .padding(.top, 40)
        .screenAppearAnalytics(name: "CreateAccountView")
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.createAccountView(router: router)
    }
    .previewEnvironment()
}
