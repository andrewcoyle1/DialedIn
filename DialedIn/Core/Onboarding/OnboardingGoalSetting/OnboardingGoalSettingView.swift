//
//  OnboardingGoalSettingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingGoalSettingView: View {
    
    @State private var navigationDestination: NavigationDestination?

    enum NavigationDestination {
        case overarchingObjective
    }
    
    var body: some View {
        List {
            Section {
                Text("Depending on what your goal is, we will help you by generating a custom plan to help you get there. This can be changed in future, and your plan will be updated accordingly.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Goal")
            }
        }
        .navigationTitle("Goal Setting")
        .safeAreaInset(edge: .bottom) {
            buttonSection
        }
        .navigationDestination(isPresented: Binding(
            get: {
                if case .overarchingObjective = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            OnboardingOverarchingObjectiveView()
        }
    }
    
    private var buttonSection: some View {
        Capsule()
            .frame(height: AuthConstants.buttonHeight)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.accent)
            .overlay(alignment: .center) {
                Text("Continue")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 32)
            }
            .anyButton(.press) {
                onContinuePressed()
            }
            .padding()
    }
    
    private func onContinuePressed() {
        navigationDestination = .overarchingObjective
    }
}

#Preview {
    NavigationStack {
        OnboardingGoalSettingView()
    }
    .previewEnvironment()
}
