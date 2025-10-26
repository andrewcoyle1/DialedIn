//
//  OnboardingSubscriptionPlanView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingSubscriptionPlanView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(UserManager.self) private var userManager
    @Environment(PurchaseManager.self) private var purchaseManager
    @Environment(LogManager.self) private var logManager
    
    @State private var navigateToCompleteAccountSetup: Bool = false
    @State private var selectedPlan: Plan = .annual
    @State private var isPurchasing: Bool = false
    @State private var showRestoreAlert: Bool = false
    
    @State private var showAlert: AnyAppAlert?
        
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    var body: some View {
        List {
            choosePlanSection
            includedInAllPlansSection
            tsAndCsSection
        }
        .onFirstTask {
            let target: OnboardingStep = .subscription
            let current = userManager.currentUser?.onboardingStep
            guard current == nil || current!.orderIndex < target.orderIndex else { return }
            logManager.trackEvent(event: Event.updateOnboardingStart)
            do {
                try await userManager.updateOnboardingStep(step: target)
                logManager.trackEvent(event: Event.updateOnboardingSuccess)
            } catch {
                logManager.trackEvent(event: Event.updateOnboardingFail(error: error))
            }
        }
        .navigationTitle("Subscription Plans")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $navigateToCompleteAccountSetup) {
            OnboardingCompleteAccountSetupView()
        }
        .showModal(showModal: $isPurchasing, content: {
            ProgressView()
                .tint(Color.white)
        })
        .showCustomAlert(alert: $showAlert)
        .toolbar {
            toolbarContent
        }
        .showCustomAlert(alert: Binding(
            get: { showRestoreAlert ? AnyAppAlert(title: "Restore Purchases", subtitle: "Restoring purchases is not yet implemented.") : nil },
            set: { _ in showRestoreAlert = false }
        ))
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
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
        ToolbarItem(placement: .bottomBar) {
            Button {
                onPurchase()
            } label: {
                Text("Restore Purchases")
            }
        }
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                onPurchase()
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
                        .anyButton(.press) { selectedPlan = plan }
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
    enum Event: LoggableEvent {
        case updateOnboardingStart
        case updateOnboardingSuccess
        case updateOnboardingFail(error: Error)
        
        var eventName: String {
            switch self {
            case .updateOnboardingStart:    return "OnboardingSubscription_OnboardingStepUpdate_Start"
            case .updateOnboardingSuccess:  return "OnboardingSubscription_OnboardingStepUpdate_Success"
            case .updateOnboardingFail:     return "OnboardingSubscription_OnboardingStepUpdate_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .updateOnboardingFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .updateOnboardingFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}

#Preview("Functioning") {
    NavigationStack {
        OnboardingSubscriptionPlanView()
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    NavigationStack {
        OnboardingSubscriptionPlanView()
    }
    .environment(PurchaseManager(services: MockPurchaseServices(delay: 3)))
    .previewEnvironment()
}

#Preview("Failure") {
    NavigationStack {
        OnboardingSubscriptionPlanView()
    }
    .environment(PurchaseManager(services: MockPurchaseServices(showError: true)))
    .previewEnvironment()
}

// MARK: - Helpers

private extension OnboardingSubscriptionPlanView {
    
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
            Image(systemName: selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(selectedPlan == plan ? Color.accent : Color.secondary)
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
    
    private func onRestorePressed() {
        showRestoreAlert = true
    }
    
    private func onPurchase() {
        // Placeholder flow to simulate purchase
        isPurchasing = true
        Task {
            defer { isPurchasing = false }
            do {
                try await purchaseManager.purchase()
                navigateToCompleteAccountSetup = true
            } catch {
                showAlert = AnyAppAlert(title: "Subscription Failed", subtitle: "We were unable to setup your subscription. Please try again.")
            }
        }
    }
}
