//
//  OnboardingHeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingHeightView: View {
    
    let gender: Gender
    let dateOfBirth: Date
    @State private var unit: UnitOfLength = .centimeters
    @State private var selectedCentimeters: Int = 175
    @State private var selectedFeet: Int = 5
    @State private var selectedInches: Int = 9
    @State private var navigationDestination: NavigationDestination?
    
    // Computed properties to keep measurements synchronized
    private var heightInCentimeters: Int {
        selectedCentimeters
    }
    
    private var heightInFeet: Int {
        Int(Double(heightInCentimeters) / 30.48) // Convert cm to feet
    }
    
    private var heightInInches: Int {
        let totalInches = Int(Double(heightInCentimeters) / 2.54)
        return totalInches % 12 // Remaining inches after feet
    }
    
    enum NavigationDestination {
        case weight(gender: Gender, dateOfBirth: Date, height: Double, lengthUnitPreference: LengthUnitPreference)
    }
    
    var body: some View {
        List {
            Section {
                Picker("Units", selection: $unit) {
                    Text("Metric").tag(UnitOfLength.centimeters)
                    Text("Imperial").tag(UnitOfLength.inches)
                }
                .pickerStyle(.segmented)
            }
            .removeListRowFormatting()
            
            if unit == .centimeters {
                Section {
                    Picker("Centimeters", selection: $selectedCentimeters) {
                        ForEach(100...250, id: \.self) { value in
                            Text("\(value) cm").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .clipped()
                    .onChange(of: selectedCentimeters) { _, _ in
                        updateImperialFromCentimeters()
                    }
                } header: {
                    Text("Metric")
                }
                .removeListRowFormatting()
            } else {
                Section {
                    HStack(spacing: 12) {
                        Picker("Feet", selection: $selectedFeet) {
                            ForEach(3...8, id: \.self) { feet in
                                Text("\(feet) ft").tag(feet)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                        .clipped()
                        .onChange(of: selectedFeet) { _, _ in
                            updateCentimetersFromImperial()
                        }
                        
                        Picker("Inches", selection: $selectedInches) {
                            ForEach(0...11, id: \.self) { inch in
                                Text("\(inch) in").tag(inch)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 150)
                        .clipped()
                        .onChange(of: selectedInches) { _, _ in
                            updateCentimetersFromImperial()
                        }
                        Spacer(minLength: 0)
                    }
                } header: {
                    Text("Imperial")
                }
                .removeListRowFormatting()
            }
        }
        .navigationTitle("How tall are you?")
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
                if case .weight = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            if case let .weight(gender, dateOfBirth, height, lengthUnitPreference) = navigationDestination {
                OnboardingWeightView(gender: gender, dateOfBirth: dateOfBirth, height: height, lengthUnitPreference: lengthUnitPreference)
            } else {
                EmptyView()
            }
        }
    }
    
    enum UnitOfLength {
        case centimeters
        case inches
    }
    
    private var canSubmit: Bool {
        switch unit {
        case .centimeters:
            return (100...250).contains(selectedCentimeters)
        case .inches:
            return (3...8).contains(selectedFeet) && (0...11).contains(selectedInches)
        }
    }
    
    private func updateImperialFromCentimeters() {
        let totalInches = Int(Double(selectedCentimeters) / 2.54)
        selectedFeet = totalInches / 12
        selectedInches = totalInches % 12
    }
    
    private func updateCentimetersFromImperial() {
        let totalInches = (selectedFeet * 12) + selectedInches
        selectedCentimeters = Int(Double(totalInches) * 2.54)
    }
    
    private func onContinue() {
        let heightInCm: Double
        switch unit {
        case .centimeters:
            heightInCm = Double(selectedCentimeters)
        case .inches:
            let feet = Double(selectedFeet)
            let inch = Double(selectedInches)
            heightInCm = ((feet * 12) + inch) * 2.54
        }
        // Navigate to weight view with collected data
        let preference: LengthUnitPreference = (unit == .centimeters) ? .centimeters : .inches
        navigationDestination = .weight(gender: gender, dateOfBirth: dateOfBirth, height: heightInCm, lengthUnitPreference: preference)
    }
}

#Preview {
    NavigationStack {
        OnboardingHeightView(gender: .male, dateOfBirth: Date())
    }
    .previewEnvironment()
}
