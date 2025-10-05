//
//  OnboardingCompleteAccountSetupView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingCompleteAccountSetupView: View {
    
    @State private var navigationDestination: NavigationDestination?

    enum NavigationDestination {
        case healthData
    }

    var body: some View {
        List {
            Text("Intro to complete account setup - explain why the user needs to submit their data")
        }
        .navigationTitle("Welcome")
        .navigationBarBackButtonHidden()
        .safeAreaInset(edge: .bottom) {
            Capsule()
                .frame(height: AuthConstants.buttonHeight)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.accent)
                .padding(.horizontal)
                .overlay(alignment: .center) {
                    Text("Continue")
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 32)
                    
                }
                .anyButton(.press) {
                    navigationDestination = .healthData
                }
        }
        .navigationDestination(isPresented: Binding(
            get: { navigationDestination == .healthData },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            OnboardingHealthDataView()
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingCompleteAccountSetupView()
    }
    .previewEnvironment()
}
