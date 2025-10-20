//
//  OnboardingSubscriptionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingSubscriptionView: View {
    @Environment(DependencyContainer.self) private var container

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
        
    var body: some View {
        List {
            whySubscribeSection
        }
        .navigationTitle("Subscription")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden()
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
        }
        #endif
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            NavigationLink {
                OnboardingSubscriptionPlanView()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private var whySubscribeSection: some View {
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
