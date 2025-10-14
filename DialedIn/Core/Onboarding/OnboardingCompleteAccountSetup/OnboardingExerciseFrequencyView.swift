//
//  OnboardingExerciseFrequencyView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingExerciseFrequencyView: View {
    
    let gender: Gender
    let dateOfBirth: Date
    let height: Double
    let weight: Double
    let lengthUnitPreference: LengthUnitPreference
    let weightUnitPreference: WeightUnitPreference
    
    @State private var selectedFrequency: ExerciseFrequency?
    @State private var navigationDestination: NavigationDestination?
    
    enum NavigationDestination {
        case activity(gender: Gender, dateOfBirth: Date, height: Double, weight: Double, exerciseFrequency: ExerciseFrequency, lengthUnitPreference: LengthUnitPreference, weightUnitPreference: WeightUnitPreference)
    }
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    var body: some View {
        List {
            exerciseFrequencySection
        }
        .navigationTitle("Exercise Frequency")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
        #endif
        .navigationDestination(isPresented: Binding(
            get: {
                if case .activity = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            if case let .activity(gender, dateOfBirth, height, weight, exerciseFrequency, lengthUnitPreference, weightUnitPreference) = navigationDestination {
                OnboardingActivityView(gender: gender, dateOfBirth: dateOfBirth, height: height, weight: weight, exerciseFrequency: exerciseFrequency, lengthUnitPreference: lengthUnitPreference, weightUnitPreference: weightUnitPreference)
            } else {
                EmptyView()
            }
        }
    }
    
    private var exerciseFrequencySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(ExerciseFrequency.allCases, id: \.self) { frequency in
                    frequencyRow(frequency)
                }
            }
            .removeListRowFormatting()
            .padding(.horizontal)
        } header: {
            Text("How often do you exercise?")
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
            NavigationLink {
                if let frequency = selectedFrequency {
                    OnboardingActivityView(gender: gender, dateOfBirth: dateOfBirth, height: height, weight: weight, exerciseFrequency: frequency, lengthUnitPreference: lengthUnitPreference, weightUnitPreference: weightUnitPreference)
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!canSubmit)
        }
    }
    
    private var canSubmit: Bool {
        selectedFrequency != nil
    }
    
    private func frequencyRow(_ frequency: ExerciseFrequency) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(frequency.description)
                    .font(.headline)
            }
            Spacer(minLength: 8)
            Image(systemName: selectedFrequency == frequency ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(selectedFrequency == frequency ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            selectedFrequency = frequency
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationStack {
        OnboardingExerciseFrequencyView(gender: .male, dateOfBirth: Date(), height: 175, weight: 70,
                                        lengthUnitPreference: .centimeters,
                                        weightUnitPreference: .kilograms)
    }
    .previewEnvironment()
}

enum ExerciseFrequency: String, CaseIterable {
    case never = "never"
    case oneToTwo = "1-2"
    case threeToFour = "3-4"
    case fiveToSix = "5-6"
    case daily = "daily"
    
    var description: String {
        switch self {
        case .never:
            return "Never"
        case .oneToTwo:
            return "1-2 times per week"
        case .threeToFour:
            return "3-4 times per week"
        case .fiveToSix:
            return "5-6 times per week"
        case .daily:
            return "Daily"
        }
    }
}
