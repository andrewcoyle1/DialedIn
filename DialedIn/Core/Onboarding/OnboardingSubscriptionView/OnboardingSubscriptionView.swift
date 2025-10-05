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
        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    benefitRow(
                        title: "Personalized plans",
                        subtitle: "Training and nutrition tailored to your goals and schedule.",
                        systemImage: "figure.run"
                    )
                    benefitRow(
                        title: "Smart coaching",
                        subtitle: "Daily guidance powered by your data and AI insights.",
                        systemImage: "brain.head.profile"
                    )
                    benefitRow(
                        title: "Progress tracking",
                        subtitle: "See trends, weekly summaries, and PRs at a glance.",
                        systemImage: "chart.line.uptrend.xyaxis"
                    )
                    benefitRow(
                        title: "HealthKit sync",
                        subtitle: "Automatically log workouts and recovery from Apple Health.",
                        systemImage: "heart.circle"
                    )
                    benefitRow(
                        title: "Accountability",
                        subtitle: "Reminders and nudges to help you stay consistent.",
                        systemImage: "bell.badge"
                    )
                }
                .padding(.vertical, 4)
            } header: {
                Text("Why subscribe?")
            }
        }
        .navigationTitle("Subscription")
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

// MARK: - Helpers

private extension OnboardingSubscriptionView {
    func benefitRow(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(Color.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}
