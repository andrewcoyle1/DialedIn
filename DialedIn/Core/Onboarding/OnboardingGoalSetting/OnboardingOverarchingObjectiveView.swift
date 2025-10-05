//
//  OnboardingOverarchingObjectiveView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingOverarchingObjectiveView: View {
    
    @State private var selectedObjective: OverarchingObjective?
    @State private var navigationDestination: NavigationDestination?

    enum NavigationDestination {
        case targetWeight(OverarchingObjective)
        case customisingProgramm
    }
    var body: some View {
        List {
            objectiveSection
        }
        .navigationTitle("What is your goal?")
        .safeAreaInset(edge: .bottom) {
            continueButton
        }
        .navigationDestination(isPresented: Binding(
            get: {
                if case .targetWeight = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            if case let .targetWeight(objective) = navigationDestination {
                OnboardingTargetWeightView(objective: objective)
            } else {
                EmptyView()
            }
        }
        .navigationDestination(isPresented: Binding(
            get: {
                if case .customisingProgramm = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            OnboardingCustomisingProgramView()
        }
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

    private var canContinue: Bool { selectedObjective != nil }

    private var continueButton: some View {
        Capsule()
            .frame(height: AuthConstants.buttonHeight)
            .frame(maxWidth: .infinity)
            .foregroundStyle(canContinue ? Color.accent : Color.gray.opacity(0.3))
            .padding(.horizontal)
            .overlay(alignment: .center) {
                Text("Continue")
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 32)
            }
            .allowsHitTesting(canContinue)
            .anyButton(.press) {
                onContinue()
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

    private func onContinue() {
        guard let selectedObjective else { return }
        if selectedObjective == .maintain {
            navigationDestination = .customisingProgramm
        } else {
            navigationDestination = .targetWeight(selectedObjective)
        }
    }
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
