//
//  OnboardingCompletedView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct OnboardingCompletedViewDelegate {
    var path: Binding<[OnboardingPathOption]>
}

struct OnboardingCompletedView: View {

    @State var viewModel: OnboardingCompletedViewModel

    var delegate: OnboardingCompletedViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView

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
                    viewModel.showDebugView = true
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        .sheet(isPresented: $viewModel.showDebugView) {
            devSettingsView()
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
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    builder.onboardingCompletedView(
        delegate: OnboardingCompletedViewDelegate(
            path: $path
        )
    )
    .previewEnvironment()
}
