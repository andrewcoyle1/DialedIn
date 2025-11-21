//
//  CreateAccountView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/9/24.
//

import SwiftUI
import CustomRouting

struct CreateAccountView: View {
    @State var viewModel: CreateAccountViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Text(viewModel.subtitle)
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
                viewModel.onSignInApplePressed(onDismiss: { dismiss() })
            }
            .frame(height: 56)
            .frame(maxWidth: 320)
            
            SignInWithGoogleButtonView(style: .light, scheme: .signUpWithGoogle) {
                viewModel.onSignInGooglePressed(onDismiss: { dismiss() })
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
    NavigationStack {
        Text("Hello")
            .sheet(isPresented: Binding.constant(true)) {
                RouterView { router in
                    builder.createAccountView(router: router)
                }
            }
            .presentationDetents([.fraction(0.25)])
    }
    .previewEnvironment()
}
