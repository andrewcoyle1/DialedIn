//
//  ManageSubscriptionView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI

struct ManageSubscriptionView: View {
    // UI-only state; wiring will be added later
    @State var isPremium: Bool = false
    @State private var isLoading: Bool = false
    @State private var selectedPlan: PlanOption = .annual
    @State private var showLegalDisclaimer: Bool = true

    private let benefits: [String] = [
        "Unlimited workouts & templates",
        "Advanced analytics & insights",
        "Priority support",
        "Cloud sync across devices",
        "Early access to new features"
    ]

    var body: some View {
        List {
            subscriptionHeader
            planPickerSection
            benefitsSection
            billingSection
            legalSection
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Manage Subscription")
        .safeAreaInset(edge: .bottom) {
            purchaseBar
        }
    }
}

#Preview("Free User") {
    NavigationStack {
        ManageSubscriptionView()
    }
        .previewEnvironment()
}

#Preview("Paid User") {
    NavigationStack {
        ManageSubscriptionView(isPremium: true)
    }
        .previewEnvironment()
}

// MARK: - Subviews

extension ManageSubscriptionView {
    private var subscriptionHeader: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: isPremium ? "crown.fill" : "person.crop.circle")
                        .foregroundStyle(isPremium ? .yellow : .secondary)
                        .font(.system(size: 30))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isPremium ? "DialedIn Pro" : "DialedIn Free")
                            .font(.headline)
                        if isPremium {
                            Text("You're subscribed to Pro.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Upgrade to Pro to unlock all features, insights, and support.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer(minLength: 0)
                    statusBadge
                }
                if isPremium {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                        Text("Auto-renewing")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.open.fill").foregroundStyle(.secondary)
                        Text("Limited access")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Your Subscription")
        }
    }

    private var statusBadge: some View {
        Group {
            if isPremium {
                Text("PRO")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            } else {
                Text("FREE")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.15))
                    .foregroundStyle(.secondary)
                    .clipShape(Capsule())
            }
        }
    }

    private var planPickerSection: some View {
        Section(header: Text("Plans")) {
            VStack(spacing: 12) {
                planRow(
                    title: "Annual",
                    subtitle: "Best value",
                    price: "$59.99/year",
                    trial: "7‑day free trial",
                    isSelected: selectedPlan == .annual
                ) {
                    selectedPlan = .annual
                }
                planRow(
                    title: "Monthly",
                    subtitle: "Flexible",
                    price: "$7.99/month",
                    trial: "7‑day free trial",
                    isSelected: selectedPlan == .monthly
                ) {
                    selectedPlan = .monthly
                }
            }
        }
    }
    
    // swiftlint:disable:next function_parameter_count
    private func planRow(title: String, subtitle: String, price: String, trial: String?, isSelected: Bool, onSelect: @escaping () -> Void) -> some View {
        Button(action: onSelect) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "calendar")
                        .foregroundStyle(.blue)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                        if subtitle.isEmpty == false {
                            Text(subtitle.uppercased())
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                        Spacer(minLength: 0)
                        Text(price)
                            .font(.subheadline.weight(.semibold))
                    }
                    if let trialText = trial {
                        Text(trialText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var benefitsSection: some View {
        Section(header: Text("What's included")) {
            ForEach(benefits, id: \.self) { benefit in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text(benefit)
                }
            }
        }
    }

    private var billingSection: some View {
        Section(header: Text("Billing")) {
            Button {
                // TODO: Trigger restore purchases
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Restore Purchases")
                }
            }
            .disabled(isLoading)

            Button {
                // TODO: Present system manage subscriptions
            } label: {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.secondary)
                    Text("Manage via App Store")
                }
            }
            .disabled(isLoading)
        }
    }

    private var legalSection: some View {
        Section(header: Text("Legal"), footer: legalFooter) {
            if let tosURL = URL(string: Constants.termsofServiceURL) {
                Link(destination: tosURL) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundStyle(.secondary)
                        Text("Terms of Service")
                    }
                }
            }
            if let privacyURL = URL(string: Constants.privacyPolicyURL) {
                Link(destination: privacyURL) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(.secondary)
                        Text("Privacy Policy")
                    }
                }
            }
        }
    }

    private var legalFooter: some View {
        Group {
            if showLegalDisclaimer {
                Text("Payment will be charged to your Apple ID account upon confirmation of purchase. Subscription automatically renews unless canceled at least 24 hours before the end of the current period. You can manage and cancel your subscription in your App Store account settings.")
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }

    private var purchaseBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(ctaTitle)
                    .font(.headline)
                Text(ctaSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Button {
                // TODO: Trigger purchase flow for selectedPlan
            } label: {
                Text(isPremium ? "Manage" : primaryButtonTitle)
                    .frame(minWidth: 140)
                    .frame(height: 44)
            }
            .buttonStyle(.glassProminent)
            .disabled(isLoading)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private var ctaTitle: String {
        if isPremium { return "You're on Pro" }
        switch selectedPlan {
        case .annual: return "Start 7‑day free trial"
        case .monthly: return "Start 7‑day free trial"
        }
    }

    private var ctaSubtitle: String {
        if isPremium { return "Auto‑renewing. Cancel anytime." }
        switch selectedPlan {
        case .annual: return "$59.99/year after trial"
        case .monthly: return "$7.99/month after trial"
        }
    }

    private var primaryButtonTitle: String {
        if isPremium { return "Manage" }
        switch selectedPlan {
        case .annual: return "Continue"
        case .monthly: return "Continue"
        }
    }
}

// MARK: - Models

extension ManageSubscriptionView {
    enum PlanOption: Hashable {
        case monthly
        case annual
    }
}
