//
//  OnboardingProteinIntakeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingProteinIntakeView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(NutritionManager.self) private var nutritionManager
    
    let preferredDiet: PreferredDiet
    let calorieFloor: CalorieFloor
    let trainingType: TrainingType
    let calorieDistribution: CalorieDistribution
    
    @State private var selectedProteinIntake: ProteinIntake?
    
    @State private var navigateToNextStep: Bool = false
    @State private var showModal: Bool = false
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
        
    var body: some View {
        List {
            pickerSection
        }
        .navigationTitle("Protein Intake")
        .navigationDestination(isPresented: $navigateToNextStep) {
            OnboardingDietPlanView()
        }
        .toolbar {
            toolbarContent
        }
        .showModal(showModal: $showModal) {
            ProgressView()
                .tint(Color.white)
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
        #endif
    }
    
    private func createPlan() {
        showModal = true
        logManager.trackEvent(event: Event.createPlanStart)
        Task {
            do {
                if let proteinIntake = selectedProteinIntake {
                    try await nutritionManager.createAndSaveDietPlan(
                        user: userManager.currentUser,
                        preferredDiet: preferredDiet,
                        calorieFloor: calorieFloor,
                        trainingType: trainingType,
                        calorieDistribution: calorieDistribution,
                        proteinIntake: proteinIntake
                    )
                    logManager.trackEvent(event: Event.createPlanSuccess)
                    navigateToNextStep = true
                }
            } catch {
                logManager.trackEvent(event: Event.createPlanFail(error: error))
            }
            showModal = false
        }
    }
    
    private var pickerSection: some View {
        ForEach(ProteinIntake.allCases) { intake in
            Section {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(intake.description)
                            .font(.headline)
                        Text(intake.detailedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: selectedProteinIntake == intake ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(selectedProteinIntake == intake ? .accent : .secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture { selectedProteinIntake = intake }
                .padding(.vertical)
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
                createPlan()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(selectedProteinIntake == nil)
        }
    }
}

enum ProteinIntake: String, CaseIterable, Identifiable {
    case low
    case moderate
    case high
    case veryHigh
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .low:
            return "Low"
        case .moderate:
            return "Moderate"
        case .high:
            return "High"
        case .veryHigh:
            return "Very High"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .low:
            return "On the low side of the optimal range."
        case .moderate:
            return "In the middle of the optimal range."
        case .high:
            return "On the high end of the optimal range."
        case .veryHigh:
            return "Highest recommended intake."
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingProteinIntakeView(preferredDiet: .balanced, calorieFloor: .standard, trainingType: .weightlifting, calorieDistribution: .even)
    }
    .previewEnvironment()
}

extension OnboardingProteinIntakeView {
    enum Event: LoggableEvent {
        case createPlanStart
        case createPlanSuccess
        case createPlanFail(error: Error)

        var eventName: String {
            switch self {
            case .createPlanStart:   return "OnboardingDietPlan_CreatePlan_Start"
            case .createPlanSuccess: return "OnboardingDietPlan_CreatePlan_Success"
            case .createPlanFail:    return "OnboardingDietPlan_CreatePlan_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .createPlanFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .createPlanFail:
                return .severe
            default:
                return .analytic
                
            }
        }
    }
}
