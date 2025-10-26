//
//  OnboardingDietPlanView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingDietPlanView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(UserManager.self) private var userManager
    @Environment(NutritionManager.self) private var nutritionManager
    @Environment(LogManager.self) private var logManager
    @Environment(AppState.self) private var appState
    
    @State private var plan: DietPlan?
    
    @State private var showAlert: AnyAppAlert?
    @State private var isLoading: Bool = false
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
        
    var body: some View {
        List {
            if let plan {
                chartSection
                overviewSection(plan)
                weeklyBreakdownSection(plan)
            } else {
                Section {
                    Text("Generating your plan…")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Your Diet Plan")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
        .task {
            await updateOnboardingStep()
        }
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $isLoading) {
            ProgressView()
                .tint(Color.white)
        }
    }
    
    private func updateOnboardingStep() async {
        let target: OnboardingStep = .diet
        if let current = userManager.currentUser?.onboardingStep, current.orderIndex >= target.orderIndex {
            return
        }
        isLoading = true
        logManager.trackEvent(event: Event.updateOnboardingStepStart)
        do {
            try await userManager.updateOnboardingStep(step: target)
            logManager.trackEvent(event: Event.updateOnboardingStepSuccess)
        } catch {
            showAlert = AnyAppAlert(title: "Unable to update your progress", subtitle: "Please check your internet connection and try again.", buttons: {
                AnyView(
                    HStack {
                        Button {
                            
                        } label: {
                            Text("Dismiss")
                        }
                        
                        Button {
                            Task {
                                await updateOnboardingStep()
                            }
                        } label: {
                            Text("Try again")
                        }
                    }
                )
            })
            logManager.trackEvent(event: Event.updateOnboardingStepFail(error: error))
        }
        isLoading = false
    }
    
    private func onContinuePressed() {
        isLoading = true
        Task {
            logManager.trackEvent(event: Event.finishOnboardingStart)
            do {
                try await userManager.updateOnboardingStep(step: .complete)
                logManager.trackEvent(event: Event.finishOnboardingSuccess)
            } catch {
                showAlert = AnyAppAlert(title: "Unable to update your profile", subtitle: "Please check your internet connection and try again")
                logManager.trackEvent(event: Event.finishOnboardingFail(error: error))
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingDietPlanView()
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    NavigationStack {
        OnboardingDietPlanView()
    }
    .environment(UserManager(services: MockUserServices(user: .mock, delay: 3)))
    .previewEnvironment()
}

#Preview("Slow Failure") {
    NavigationStack {
        OnboardingDietPlanView()
    }
    .environment(UserManager(services: MockUserServices(user: .mock, delay: 3, showError: true)))
    .previewEnvironment()
}

#Preview("Failure") {
    NavigationStack {
        OnboardingDietPlanView()
    }
    .environment(UserManager(services: MockUserServices(user: .mock, showError: true)))
    .previewEnvironment()
}

extension OnboardingDietPlanView {
    
    private var chartSection: some View {
        Section("Weekly Calorie & Macro Breakdown") {
            if let plan {
                WeeklyMacroChart(plan: plan)
            }
        }
    }
    
    private func overviewSection(_ plan: DietPlan) -> some View {
        Section("Overview") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Estimated TDEE: \(Int(plan.tdeeEstimate)) kcal/day")
                Text("Preferred diet: \(plan.preferredDiet.capitalized)")
                Text("Calorie floor: \(plan.calorieFloor.capitalized)")
                Text("Training focus: \(plan.trainingType.replacingOccurrences(of: "_", with: " ").capitalized)")
                Text("Distribution: \(plan.calorieDistribution.capitalized)")
                Text("Protein: \(plan.proteinIntake.capitalized)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }
    
    private func weeklyBreakdownSection(_ plan: DietPlan) -> some View {
        Section("7-day targets") {
            ForEach(Array(plan.days.enumerated()), id: \.offset) { idx, day in
                VStack(alignment: .leading, spacing: 6) {
                    Text("Day \(idx + 1)")
                        .font(.headline)
                    HStack(spacing: 16) {
                        labelValue("Calories", "\(Int(day.calories)) kcal")
                        labelValue("Protein", "\(Int(day.proteinGrams)) g")
                    }
                    HStack(spacing: 16) {
                        labelValue("Carbs", "\(Int(day.carbGrams)) g")
                        labelValue("Fat", "\(Int(day.fatGrams)) g")
                    }
                }
                .padding(.vertical, 6)
            }
        }
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
            Button {
                onContinuePressed()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private func labelValue(_ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
    
    enum Event: LoggableEvent {
        case updateOnboardingStepStart
        case updateOnboardingStepSuccess
        case updateOnboardingStepFail(error: Error)
        case finishOnboardingStart
        case finishOnboardingSuccess
        case finishOnboardingFail(error: Error)
        
        var eventName: String {
            switch self {
            case .updateOnboardingStepStart:    return "DietView_UpdateOnboardingStep_Start"
            case .updateOnboardingStepSuccess:  return "DietView_UpdateOnboardingStep_Success"
            case .updateOnboardingStepFail:     return "DietView_UpdateOnboardingStep_Fail"
            case .finishOnboardingStart:        return "DietView_FinishOnboarding_Start"
            case .finishOnboardingSuccess:      return "DietView_FinishOnboarding_Success"
            case .finishOnboardingFail:         return "DietView_FinishOnboarding_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .finishOnboardingFail(error: let error), .updateOnboardingStepFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .finishOnboardingFail, .updateOnboardingStepFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
