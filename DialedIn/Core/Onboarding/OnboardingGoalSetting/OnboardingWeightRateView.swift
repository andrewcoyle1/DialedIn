//
//  OnboardingWeightRateView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingWeightRateView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    let objective: OverarchingObjective
    let targetWeight: Double
    @State private var navigationDestination: NavigationDestination?
    @State private var currentWeight: Double = 0
    @State private var weightUnit: WeightUnitPreference = .kilograms
    @State private var didInitialize: Bool = false
    @State private var weightChangeRate: Double = 0.5 // kg/week
    
    @State private var isLoading: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    enum NavigationDestination {
        case customisingProgram
    }
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    enum WeightRateCategory {
        case conservative, standard, aggressive
        
        var title: String {
            switch self {
            case .conservative: return "Conservative"
            case .standard: return "Standard (Recommended)"
            case .aggressive: return "Aggressive"
            }
        }
    }
    
    // MARK: - Constants
    private let minWeightChangeRate: Double = 0.25 // kg/week
    private let maxWeightChangeRate: Double = 1.5  // kg/week
    private let conservativeThreshold: Double = 0.4 // kg/week
    private let aggressiveThreshold: Double = 0.8  // kg/week
    
    private var currentRateCategory: WeightRateCategory {
        if weightChangeRate <= conservativeThreshold {
            return .conservative
        } else if weightChangeRate >= aggressiveThreshold {
            return .aggressive
        } else {
            return .standard
        }
    }
    
    var body: some View {
        List {
            if didInitialize {
                rateSelectionSection
                rateDetailsSection
                additionalInfoSection
            } else {
                loadingSection
            }
        }
        .showModal(showModal: Binding(
            get: { isLoading },
            set: { _ in }
        )) {
            ProgressView()
                .tint(.white)
        }
        .navigationTitle("At what rate?")
        .onFirstAppear {
            onAppear()
        }
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
        #endif
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
                OnboardingGoalSummaryView(objective: objective, targetWeight: targetWeight, weightRate: weightChangeRate)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
    
    private var rateSelectionSection: some View {
        Section {
            VStack(spacing: 16) {
                Text(currentRateCategory.title)
                    .font(.headline)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Native SwiftUI Slider
                VStack(spacing: 8) {
                    Slider(
                        value: $weightChangeRate,
                        in: minWeightChangeRate...maxWeightChangeRate,
                        step: 0.05
                    )
                    .tint(.green)
                    .disabled(isLoading)
                    
                    // Tick marks and labels
                    HStack {
                        ForEach([minWeightChangeRate, (minWeightChangeRate + maxWeightChangeRate) / 2, maxWeightChangeRate], id: \.self) { value in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.6))
                                    .frame(width: 1, height: 8)
                                Text("\(String(format: "%.1f", value))")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            if value < maxWeightChangeRate {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding()
            }
            .padding(.vertical, 8)
        }
        .removeListRowFormatting()
    }
    
    private var rateDetailsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(weeklyWeightChangeText)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(monthlyWeightChangeText)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        .removeListRowFormatting()
        .padding(.horizontal)
    }
    
    private var additionalInfoSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(estimatedCalorieTargetText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                
                Text(estimatedEndDateText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        .removeListRowFormatting()
        .padding(.horizontal)

    }
    
    private var loadingSection: some View {
        Section {
            ProgressView()
                .frame(height: 200)
                .frame(maxWidth: .infinity)
        }
        .removeListRowFormatting()
    }
    
    private var canContinue: Bool { weightChangeRate > 0 }
    
    // MARK: - Computed Properties
    
    private var weeklyWeightChangeText: String {
        let weeklyChangeInKg = weightChangeRate
        let weeklyChangeInPounds = weightUnit == .pounds ? weeklyChangeInKg * 2.20462 : weeklyChangeInKg
        let unitText = weightUnit == .pounds ? "lbs" : "kg"
        let sign = objective == .loseWeight ? "-" : "+"
        let percentBW = (weeklyChangeInKg / currentWeight) * 100
        
        return "\(sign)\(String(format: "%.2f", weeklyChangeInPounds)) \(unitText) (\(String(format: "%.1f", percentBW))% BW) / Week"
    }
    
    private var monthlyWeightChangeText: String {
        let monthlyChangeInKg = weightChangeRate * 4 // Approximate monthly rate
        let monthlyChangeInPounds = weightUnit == .pounds ? monthlyChangeInKg * 2.20462 : monthlyChangeInKg
        let unitText = weightUnit == .pounds ? "lbs" : "kg"
        let sign = objective == .loseWeight ? "-" : "+"
        let percentBW = (monthlyChangeInKg / currentWeight) * 100
        
        return "\(sign)\(String(format: "%.2f", monthlyChangeInPounds)) \(unitText) (\(String(format: "%.1f", percentBW))% BW) / Month"
    }
    
    private var estimatedCalorieTargetText: String {
        let weeklyChangeInKg = weightChangeRate
        let weeklyChangeInPounds = weightUnit == .pounds ? weeklyChangeInKg * 2.20462 : weeklyChangeInKg
        
        // Rough estimate: 1 lb = ~3500 calories, so weekly deficit/surplus
        let weeklyCalorieChange = weeklyChangeInPounds * 3500
        let dailyCalorieChange = weeklyCalorieChange / 7
        
        let baseCalories = 2000.0 // Rough BMR estimate
        let targetCalories = objective == .loseWeight ? 
            baseCalories - dailyCalorieChange : 
            baseCalories + dailyCalorieChange
        
        return "~ \(Int(targetCalories)) kcal estimated daily calorie target"
    }
    
    private var estimatedEndDateText: String {
        let totalWeightChange = abs(targetWeight - currentWeight)
        let weeklyChangeInKg = weightChangeRate
        let weeksToGoal = totalWeightChange / weeklyChangeInKg
        
        let endDate = Calendar.current.date(byAdding: .weekOfYear, value: Int(weeksToGoal), to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return "Approximate end date: \(formatter.string(from: endDate))"
    }
    
    // MARK: - Helper Methods
    
    private func onAppear() {
        let user = userManager.currentUser
        currentWeight = user?.weightKilograms ?? 70
        weightUnit = user?.weightUnitPreference ?? .kilograms
        
        // Set default rate based on objective
        switch objective {
        case .loseWeight, .gainWeight:
            weightChangeRate = 0.5 // Standard rate
        case .maintain:
            weightChangeRate = 0.25 // Conservative rate
        }
        
        didInitialize = true
    }
}

#Preview("Gain Weight") {
    NavigationStack {
        OnboardingWeightRateView(objective: .gainWeight, targetWeight: 80)
    }
    .previewEnvironment()
}

#Preview("Lose Weight") {
    NavigationStack {
        OnboardingWeightRateView(objective: .loseWeight, targetWeight: 60)
    }
    .previewEnvironment()
}
