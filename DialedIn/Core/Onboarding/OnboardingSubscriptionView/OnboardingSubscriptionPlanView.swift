//
//  OnboardingSubscriptionPlanView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingSubscriptionPlanView: View {

    @State private var navigateToCompleteAccountSetup: Bool = false
    @State private var selectedPlan: Plan = .annual
    @State private var isPurchasing: Bool = false
    @State private var showRestoreAlert: Bool = false
    
    enum Plan: String, CaseIterable, Identifiable {
        case monthly
        case annual
        case lifetime
        
        var id: String { rawValue }
        
        var title: String {
            switch self {
            case .monthly: return "Monthly"
            case .annual: return "Annual"
            case .lifetime: return "Lifetime"
            }
        }
        
        var subtitle: String {
            switch self {
            case .monthly: return "$9.99 / month"
            case .annual: return "$69.99 / year (save 40%)"
            case .lifetime: return "$199.99 one-time"
            }
        }
        
        var badge: String? {
            switch self {
            case .annual: return "Best Value"
            default: return nil
            }
        }
    }
    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    ForEach(Plan.allCases) { plan in
                        planRow(plan)
                            .contentShape(Rectangle())
                            .anyButton(.press) { selectedPlan = plan }
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Choose your plan")
            }
            
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
            
            Section {
                Text("By subscribing, you agree to our [Terms of Service](Constants.termsofServiceURL) and [Privacy Policy](Constants.privacyPolicyURL)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            .removeListRowFormatting()
            .padding(.horizontal)
        }
        .navigationDestination(isPresented: $navigateToCompleteAccountSetup) {
            OnboardingCompleteAccountSetupView()
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 12) {
                Capsule()
                    .frame(height: 50)
                    .foregroundStyle(Color.gray.opacity(0.2))
                    .overlay {
                        Text("Restore")
                            .foregroundStyle(Color.primary)
                    }
                    .anyButton(.press) {
                        showRestoreAlert = true
                    }
                Capsule()
                    .frame(height: 50)
                    .foregroundStyle(isPurchasing ? Color.gray.opacity(0.3) : Color.accent)
                    .overlay(alignment: .center) {
                        if isPurchasing {
                            ProgressView().tint(.white)
                        } else {
                            Text("Continue")
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 32)
                        }
                    }
                    .allowsHitTesting(!isPurchasing)
                    .anyButton(.press) {
                        onPurchase()
                    }
            }
            .padding(.horizontal)
        }
        .showCustomAlert(alert: Binding(
            get: { showRestoreAlert ? AnyAppAlert(title: "Restore Purchases", subtitle: "Restoring purchases is not yet implemented.") : nil },
            set: { _ in showRestoreAlert = false }
        ))
    }
}

#Preview {
    NavigationStack {
        OnboardingSubscriptionPlanView()
    }
    .previewEnvironment()
}

// MARK: - Helpers

private extension OnboardingSubscriptionPlanView {
    func planRow(_ plan: Plan) -> some View {
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
            Image(systemName: selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(selectedPlan == plan ? Color.accent : Color.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    func featureRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(Color.accent)
            Text(text)
                .font(.subheadline)
        }
    }
    
    func onPurchase() {
        // Placeholder flow to simulate purchase
        isPurchasing = true
        Task {
            defer { isPurchasing = false }
            try? await Task.sleep(for: .seconds(1.0))
            navigateToCompleteAccountSetup = true
        }
    }
}
