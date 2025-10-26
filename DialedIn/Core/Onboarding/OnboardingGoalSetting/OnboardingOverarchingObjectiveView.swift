//
//  OnboardingOverarchingObjectiveView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingOverarchingObjectiveView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(UserManager.self) private var userManager
    
    let isStandaloneMode: Bool
    
    @State private var selectedObjective: OverarchingObjective?
    @State private var userWeight: Double?
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    init(isStandaloneMode: Bool = false) {
        self.isStandaloneMode = isStandaloneMode
    }
        
    var body: some View {
        List {
            objectiveSection
        }
        .navigationTitle("What is your goal?")
        .toolbar {
            toolbarContent
        }
        .onAppear {
            userWeight = userManager.currentUser?.weightKilograms
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
    }
    
    private var objectiveSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(OverarchingObjective.allCases, id: \.self) { objective in
                    objectiveRow(objective)
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Choose one")
        }
    }

    private func objectiveRow(_ objective: OverarchingObjective) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(objective.description)
                    .font(.headline)
                Text(objective.detailedDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: selectedObjective == objective ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(selectedObjective == objective ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            selectedObjective = objective
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
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
                if let objective = selectedObjective, let weight = userWeight {
                    if objective != .maintain {
                        OnboardingTargetWeightView(objective: objective, isStandaloneMode: isStandaloneMode)
                    } else {
                        OnboardingGoalSummaryView(objective: objective, targetWeight: weight, weightRate: 0, isStandaloneMode: isStandaloneMode)
                    }
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!canContinue)
        }
    }

    private var canContinue: Bool { selectedObjective != nil && userWeight != nil }

}

#Preview {
    NavigationStack {
        OnboardingOverarchingObjectiveView()
    }
    .previewEnvironment()
}

enum OverarchingObjective: CaseIterable {
    case loseWeight
    case maintain
    case gainWeight

    var description: String {
        switch self {
        case .loseWeight:
            "Lose weight"
        case .maintain:
            "Maintain"
        case .gainWeight:
            "Gain weight"
        }
    }

    var detailedDescription: String {
        switch self {
        case .loseWeight:
            "Goal of losing weight"
        case .maintain:
            "Goal of maintaining weight"
        case .gainWeight:
            "Goal of gaining weight"
        }
    }
}
