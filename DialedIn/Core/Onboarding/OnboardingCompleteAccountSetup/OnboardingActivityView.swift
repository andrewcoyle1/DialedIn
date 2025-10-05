//
//  OnboardingActivityView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingActivityView: View {
    
    let gender: Gender
    let dateOfBirth: Date
    let height: Double
    let weight: Double
    let exerciseFrequency: ExerciseFrequency
    let lengthUnitPreference: LengthUnitPreference
    let weightUnitPreference: WeightUnitPreference
    
    @State private var selectedActivityLevel: ActivityLevel?
    @State private var navigationDestination: NavigationDestination?
    
    enum NavigationDestination {
        case cardioFitness(gender: Gender, dateOfBirth: Date, height: Double, weight: Double, exerciseFrequency: ExerciseFrequency, activityLevel: ActivityLevel, lengthUnitPreference: LengthUnitPreference, weightUnitPreference: WeightUnitPreference)
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's your daily activity level outside of exercise?")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                    
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        activityRow(level)
                    }
                }
                .removeListRowFormatting()
                .padding(.horizontal)
            } header: {
                Text("Daily Activity")
            }
        }
        .navigationTitle("Activity Level")
        .safeAreaInset(edge: .bottom) {
            Capsule()
                .frame(height: AuthConstants.buttonHeight)
                .frame(maxWidth: .infinity)
                .foregroundStyle(canSubmit ? Color.accent : Color.gray.opacity(0.3))
                .padding(.horizontal)
                .overlay(alignment: .center) {
                    Text("Continue")
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 32)
                }
                .allowsHitTesting(canSubmit)
                .anyButton(.press) {
                    onContinue()
                }
        }
        .navigationDestination(isPresented: Binding(
            get: {
                if case .cardioFitness = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            if case let .cardioFitness(gender, dateOfBirth, height, weight, exerciseFrequency, activityLevel, lengthUnitPreference, weightUnitPreference) = navigationDestination {
                OnboardingCardioFitnessView(gender: gender, dateOfBirth: dateOfBirth, height: height, weight: weight, exerciseFrequency: exerciseFrequency, activityLevel: activityLevel, lengthUnitPreference: lengthUnitPreference, weightUnitPreference: weightUnitPreference)
            } else {
                EmptyView()
            }
        }
    }
    
    private var canSubmit: Bool {
        selectedActivityLevel != nil
    }
    
    private func activityRow(_ level: ActivityLevel) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(level.description)
                    .font(.headline)
                Text(level.detailDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: selectedActivityLevel == level ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(selectedActivityLevel == level ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            selectedActivityLevel = level
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func onContinue() {
        guard let selectedActivityLevel = selectedActivityLevel else { return }
        // Navigate to cardio fitness view with collected data
        navigationDestination = .cardioFitness(gender: gender, dateOfBirth: dateOfBirth, height: height, weight: weight, exerciseFrequency: exerciseFrequency, activityLevel: selectedActivityLevel, lengthUnitPreference: lengthUnitPreference, weightUnitPreference: weightUnitPreference)
    }
}

#Preview {
    NavigationStack {
        OnboardingActivityView(
            gender: .male, 
            dateOfBirth: Date(), 
            height: 175, 
            weight: 70,
            exerciseFrequency: .threeToFour,
            lengthUnitPreference: .centimeters,
            weightUnitPreference: .kilograms
        )
    }
    .previewEnvironment()
}

enum ActivityLevel: String, CaseIterable {
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case active = "active"
    case veryActive = "very_active"
    
    var description: String {
        switch self {
        case .sedentary:
            return "Sedentary"
        case .light:
            return "Light Activity"
        case .moderate:
            return "Moderate Activity"
        case .active:
            return "Active"
        case .veryActive:
            return "Very Active"
        }
    }
    
    var detailDescription: String {
        switch self {
        case .sedentary:
            return "Desk job, minimal walking, mostly sitting"
        case .light:
            return "Light walking, some daily activities, occasional stairs"
        case .moderate:
            return "Regular walking, standing work, daily movement"
        case .active:
            return "Active lifestyle, frequent movement, manual work"
        case .veryActive:
            return "Highly active, constant movement, physically demanding"
        }
    }
}
