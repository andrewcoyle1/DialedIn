//
//  OnboardingCompletedView.swift
//  BrainBolt
//
//  Created by Andrew Coyle on 13/08/2025.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(AppState.self) private var root
    
    @State private var isCompletingProfileSetup: Bool = false

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

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
                    showDebugView = true
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
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
            onFinishButtonPressed()
        } label: {
            ZStack {
                if !isCompletingProfileSetup {
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
        .disabled(isCompletingProfileSetup)
    }
    
    @Environment(UserManager.self) private var userManager
    
    func onFinishButtonPressed() {
        isCompletingProfileSetup = true
        Task {
            isCompletingProfileSetup = false
            // other logic to complete onboarding
            do {
                try await userManager.updateOnboardingStep(step: .complete)
            } catch {
                // Proceed even if saving goal fails
            }
            // AppView will switch to main automatically once onboardingStep is .complete
        }
    }
}

#Preview {
    OnboardingCompletedView()
        .previewEnvironment()
}
