//
//  OnboardingGoalSummaryView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 07/10/2025.
//

import SwiftUI

struct OnboardingGoalSummaryView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    let objective: OverarchingObjective
    let targetWeight: Double
    let weightRate: Double
    
    @State private var isLoading: Bool = true
    
    @State private var showAlert: AnyAppAlert?
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
        
    var body: some View {
        List {
            goalOverviewSection
            weightDetailsSection
            timelineSection
            motivationSection
        }
        .navigationTitle("Goal Summary")
        .scrollIndicators(.hidden)
        .task {
            await uploadGoalSettings()
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
        #endif
        .toolbar {
            toolbarContent
        }
        .showCustomAlert(alert: $showAlert)
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
                OnboardingCustomisingProgramView()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(isLoading)
        }
    }
    
    private func uploadGoalSettings() async {
        logManager.trackEvent(event: Event.goalSaveStart(objective: objective, targetKg: targetWeight, rateKgPerWeek: weightRate))
            defer { isLoading = false }
            do {
                try await userManager.updateGoalSettings(
                    objective: objective.description,
                    targetWeightKilograms: targetWeight,
                    weeklyChangeKilograms: weightRate
                )
                logManager.trackEvent(event: Event.goalSaveSuccess(objective: objective, targetKg: targetWeight, rateKgPerWeek: weightRate))
            } catch {
                logManager.trackEvent(event: Event.goalSaveFail(error: error, objective: objective, targetKg: targetWeight, rateKgPerWeek: weightRate))
                handleSaveError(error)
            }
    }
    
    private func handleSaveError(_ error: Error) {
        let errorInfo = AuthErrorHandler.handle(error, operation: "save goal settings", logManager: logManager)
        showAlert = AnyAppAlert(
            title: errorInfo.title,
            subtitle: errorInfo.message
        )
    }
    
    // MARK: - Computed Properties
    
    private var currentWeight: Double? {
        userManager.currentUser?.weightKilograms
    }
    
    private var weightUnit: WeightUnitPreference {
        userManager.currentUser?.weightUnitPreference ?? .kilograms
    }
    
    private var weightDifference: Double {
        guard let current = currentWeight else { return 0 }
        return targetWeight - current
    }
    
    private var estimatedWeeks: Int {
        guard weightRate > 0 else { return 0 }
        return Int(ceil(abs(weightDifference) / weightRate))
    }
    
    private var estimatedMonths: Int {
        Int(ceil(Double(estimatedWeeks) / 4.33))
    }
    
    // MARK: - View Sections
    
    private var goalOverviewSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: objectiveIcon)
                        .font(.title2)
                        .foregroundColor(.accent)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Goal")
                            .font(.headline)
                        Text(objective.description)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                
                Text(objective.detailedDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        } header: {
            Text("Goal Overview")
        }
    }
    
    private var weightDetailsSection: some View {
        Section {
            VStack(spacing: 16) {
                if let current = currentWeight {
                    weightRow(
                        title: "Current Weight",
                        weight: current,
                        unit: weightUnit
                    )
                }
                
                weightRow(
                    title: "Target Weight",
                    weight: targetWeight,
                    unit: weightUnit
                )
                
                if weightDifference != 0 {
                    Divider()
                    
                    HStack {
                        Text("Weight Change")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(weightDifference > 0 ? "+" : "")\(formatWeight(abs(weightDifference), unit: weightUnit))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(weightDifference > 0 ? .green : .red)
                    }
                    
                    HStack {
                        Text("Weekly Rate")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(formatWeight(weightRate, unit: weightUnit))/week")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Weight Details")
        }
    }
    
    private var timelineSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundColor(.accent)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Estimated Timeline")
                            .font(.headline)
                        if estimatedWeeks > 0 {
                            Text("\(estimatedWeeks) weeks (\(estimatedMonths) months)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        } else {
                            Text("Maintaining current weight")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    Spacer()
                }
                
                if estimatedWeeks > 0 {
                    Text("Based on your selected rate of \(formatWeight(weightRate, unit: weightUnit)) per week")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Timeline")
        }
    }
    
    private var motivationSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.title2)
                        .foregroundColor(.pink)
                    Text("You've Got This!")
                        .font(.headline)
                    Spacer()
                }
                
                Text(motivationalMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        } header: {
            Text("Motivation")
        }
    }
    
    // MARK: - Helper Methods
    
    private func weightRow(title: String, weight: Double, unit: WeightUnitPreference) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(formatWeight(weight, unit: unit))
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    private func formatWeight(_ weight: Double, unit: WeightUnitPreference) -> String {
        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", weight)
        case .pounds:
            let pounds = weight * 2.20462
            return String(format: "%.1f lbs", pounds)
        }
    }
    
    private var objectiveIcon: String {
        switch objective {
        case .loseWeight:
            return "arrow.down.circle.fill"
        case .maintain:
            return "equal.circle.fill"
        case .gainWeight:
            return "arrow.up.circle.fill"
        }
    }
    
    private var motivationalMessage: String {
        switch objective {
        case .loseWeight:
            return "Every step you take towards your goal is progress. Stay consistent with your nutrition and exercise, and you'll reach your target weight. Remember, sustainable changes lead to lasting results."
        case .maintain:
            return "Maintaining your current weight is a fantastic goal! Focus on balanced nutrition and regular activity to keep your body healthy and strong. Consistency is key to long-term success."
        case .gainWeight:
            return "Building healthy weight takes time and dedication. Focus on nutrient-dense foods and progressive strength training. Your body will thank you for the consistent effort."
        }
    }
    
    enum Event: LoggableEvent {
        case goalSaveStart(objective: OverarchingObjective, targetKg: Double, rateKgPerWeek: Double)
        case goalSaveSuccess(objective: OverarchingObjective, targetKg: Double, rateKgPerWeek: Double)
        case goalSaveFail(error: Error, objective: OverarchingObjective, targetKg: Double, rateKgPerWeek: Double)
        
        var eventName: String {
            switch self {
            case .goalSaveStart: return "Onboarding_Goal_Save_Start"
            case .goalSaveSuccess: return "Onboarding_Goal_Save_Success"
            case .goalSaveFail: return "Onboarding_Goal_Save_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case let .goalSaveStart(objective, targetKg, rateKgPerWeek),
                 let .goalSaveSuccess(objective, targetKg, rateKgPerWeek):
                return [
                    "objective": objective.description,
                    "target_weight_kg": targetKg,
                    "weekly_change_kg": rateKgPerWeek
                ]
            case let .goalSaveFail(error, objective, targetKg, rateKgPerWeek):
                return [
                    "objective": objective.description,
                    "target_weight_kg": targetKg,
                    "weekly_change_kg": rateKgPerWeek,
                    "error": error.localizedDescription
                ]
            }
        }
        
        var type: LogType {
            switch self {
            case .goalSaveFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview("Normal") {
    NavigationStack {
        OnboardingGoalSummaryView(objective: .gainWeight, targetWeight: 82, weightRate: 0.5)
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    NavigationStack {
        OnboardingGoalSummaryView(objective: .gainWeight, targetWeight: 82, weightRate: 0.5)
    }
    .environment(UserManager(services: MockUserServices(user: .mock, delay: 3)))
    .previewEnvironment()
}

#Preview("Failure") {
    NavigationStack {
        OnboardingGoalSummaryView(objective: .gainWeight, targetWeight: 82, weightRate: 0.5)
    }
    .previewEnvironment()
}
