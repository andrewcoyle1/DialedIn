//
//  OnboardingWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingWeightView: View {
    
    let gender: Gender
    let dateOfBirth: Date
    let height: Double
    let lengthUnitPreference: LengthUnitPreference
    
    @State private var unit: UnitOfWeight = .kilograms
    @State private var selectedKilograms: Int = 70
    @State private var selectedPounds: Int = 154
    @State private var navigationDestination: NavigationDestination?
    
    enum NavigationDestination {
        case exerciseFrequency(gender: Gender, dateOfBirth: Date, height: Double, weight: Double, lengthUnitPreference: LengthUnitPreference, weightUnitPreference: WeightUnitPreference)
    }
    
    enum UnitOfWeight {
        case kilograms
        case pounds
    }

    var body: some View {
        List {
            Section {
                Picker("Units", selection: $unit) {
                    Text("Metric").tag(UnitOfWeight.kilograms)
                    Text("Imperial").tag(UnitOfWeight.pounds)
                }
                .pickerStyle(.segmented)
            }
            .removeListRowFormatting()
            
            if unit == .kilograms {
                Section {
                    Picker("Kilograms", selection: $selectedKilograms) {
                        ForEach(30...200, id: \.self) { value in
                            Text("\(value) kg").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .clipped()
                    .onChange(of: selectedKilograms) { _, _ in
                        updatePoundsFromKilograms()
                    }
                } header: {
                    Text("Metric")
                }
                .removeListRowFormatting()
            } else {
                Section {
                    Picker("Pounds", selection: $selectedPounds) {
                        ForEach(66...440, id: \.self) { value in
                            Text("\(value) lbs").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .clipped()
                    .onChange(of: selectedPounds) { _, _ in
                        updateKilogramsFromPounds()
                    }
                } header: {
                    Text("Imperial")
                }
                .removeListRowFormatting()
            }
        }
        .navigationTitle("What's your weight?")
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
                if case .exerciseFrequency = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            if case let .exerciseFrequency(gender, dateOfBirth, height, weight, lengthUnitPreference, weightUnitPreference) = navigationDestination {
                OnboardingExerciseFrequencyView(gender: gender, dateOfBirth: dateOfBirth, height: height, weight: weight, lengthUnitPreference: lengthUnitPreference, weightUnitPreference: weightUnitPreference)
            } else {
                EmptyView()
            }
        }
    }
    
    private var canSubmit: Bool {
        switch unit {
        case .kilograms:
            return (30...200).contains(selectedKilograms)
        case .pounds:
            return (66...440).contains(selectedPounds)
        }
    }
    
    private func updatePoundsFromKilograms() {
        selectedPounds = Int(Double(selectedKilograms) * 2.20462)
    }
    
    private func updateKilogramsFromPounds() {
        selectedKilograms = Int(Double(selectedPounds) / 2.20462)
    }
    
    private func onContinue() {
        let weightInKg: Double
        let weightPreference: WeightUnitPreference
        switch unit {
        case .kilograms:
            weightInKg = Double(selectedKilograms)
            weightPreference = .kilograms
        case .pounds:
            weightInKg = Double(selectedPounds) / 2.20462
            weightPreference = .pounds
        }
        // Navigate to exercise frequency view with collected data
        navigationDestination = .exerciseFrequency(gender: gender, dateOfBirth: dateOfBirth, height: height, weight: weightInKg, lengthUnitPreference: lengthUnitPreference, weightUnitPreference: weightPreference)
    }
}

#Preview {
    NavigationStack {
        OnboardingWeightView(gender: .male, dateOfBirth: Date(), height: 175, lengthUnitPreference: .centimeters)
    }
    .previewEnvironment()
}
