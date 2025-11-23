//
//  OnboardingCompletedView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingCompletedView: View {

    @State var viewModel: OnboardingCompletedViewModel

    var body: some View {
        VStack {
            Spacer()
            content
            Spacer()
            
        }
        .safeAreaInset(edge: .bottom, content: {
            buttonSection
        })
        .padding(16)
        #if !DEBUG && !MOCK
        .navigationBarBackButtonHidden(true)
        #else
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.onDevSettingsPressed()
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        #endif
    }
    
    private var content: some View {
        VStack {
            Image(systemName: "rectangle.stack.fill.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.accent)
                .padding(.bottom, 16)
            Text("🎉 Onboarding Complete!")
                .font(.title)
                .bold()
                .padding(.bottom, 8)
            Text("You're ready to start training with Dialed!")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
        }
    }
    
    private var buttonSection: some View {
        Button {
            viewModel.onFinishButtonPressed()
        } label: {
            ZStack {
                if !viewModel.isCompletingProfileSetup {
                    Text("Continue")
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
        }
        .buttonStyle(.glassProminent)
        .disabled(viewModel.isCompletingProfileSetup)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingCompletedView(router: router)
    }
    .previewEnvironment()
}
