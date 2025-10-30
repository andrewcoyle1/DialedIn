//
//  OnboardingCompletedView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var root
    @State var viewModel: OnboardingCompletedViewModel
    @Binding var path: [OnboardingPathOption]

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
            DevSettingsView(
                viewModel: DevSettingsViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
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
                    Text("Start Training")
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
    OnboardingCompletedView(
        viewModel: OnboardingCompletedViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        ), path: $path
    )
    .previewEnvironment()
}
