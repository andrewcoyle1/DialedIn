//
//  OnboardingSubscriptionPlanView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingSubscriptionPlanView: View {

    @State var presenter: OnboardingSubscriptionPlanPresenter

    var body: some View {
        List {
            choosePlanSection
            includedInAllPlansSection
            tsAndCsSection
        }
        .onFirstTask {
            await presenter.setupView()
        }
        .navigationTitle("Subscription Plans")
        .navigationBarTitleDisplayMode(.large)
        .showModal(showModal: $presenter.isPurchasing, content: {
            ProgressView()
                .tint(Color.white)
        })
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.onPurchase()
            } label: {
                Text("Restore Purchases")
            }
        }
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.onPurchase()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private var choosePlanSection: some View {
        Section {
            VStack(spacing: 12) {
                ForEach(Plan.allCases) { plan in
                    planRow(plan)
                        .contentShape(Rectangle())
                        .anyButton(.press) {
                            presenter.selectedPlan = plan
                        }
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Choose your plan")
        }
    }
    
    private var includedInAllPlansSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                featureRow("Full workout and nutrition features")
                featureRow("AI coaching & weekly summaries")
                featureRow("Unlimited history and cloud sync")
                featureRow("Cancel anytime (non-lifetime)")
            }
            .padding(.vertical, 4)
        } header: {
            Text("Included in all plans")
        }
    }
    
    private var tsAndCsSection: some View {
        Section {
            Text("By subscribing, you agree to our [Terms of Service](Constants.termsofServiceURL) and [Privacy Policy](Constants.privacyPolicyURL)")
                .font(.caption)
                .foregroundStyle(Color.secondary)
        }
        .removeListRowFormatting()
        .padding(.horizontal)
    }
    
    private func planRow(_ plan: Plan) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(plan.title)
                        .font(.headline)
                    if let badge = plan.badge {
                        Text(badge)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(Color.accent.opacity(0.15))
                            )
                            .foregroundStyle(Color.accent)
                    }
                }
                Text(plan.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: presenter.selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(presenter.selectedPlan == plan ? Color.accent : Color.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func featureRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(Color.accent)
            Text(text)
                .font(.subheadline)
        }
    }
    
}

#Preview("Functioning") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingSubscriptionPlanView(router: router)
    }
    .previewEnvironment()
}
