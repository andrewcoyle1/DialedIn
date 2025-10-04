//
//  OnboardingSubscriptionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingSubscriptionView: View {

    @State private var navigateToSubscriptionPlans: Bool = false
    var body: some View {
        VStack {
            Text("Paywall")
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $navigateToSubscriptionPlans) {
            OnboardingSubscriptionPlanView()
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
                    navigateToSubscriptionPlans = true
                }
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingSubscriptionView()
    }
    .previewEnvironment()
}
