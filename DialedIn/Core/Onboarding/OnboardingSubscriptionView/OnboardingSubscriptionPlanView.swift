//
//  OnboardingSubscriptionPlanView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingSubscriptionPlanView: View {

    @State private var navigateToCompleteAccountSetup: Bool = false
    var body: some View {
        VStack {
            Text("Subscription Plans")
        }
        .navigationDestination(isPresented: $navigateToCompleteAccountSetup) {
            OnboardingCompleteAccountSetupView()
        }
        .safeAreaInset(edge: .bottom) {
            Capsule()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.accent)
                .padding(.horizontal)
                .overlay(alignment: .center) {
                    Text("Continue")
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 32)
                }
                .anyButton(.press) {
                    navigateToCompleteAccountSetup = true
                }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingSubscriptionPlanView()
    }
    .previewEnvironment()
}
