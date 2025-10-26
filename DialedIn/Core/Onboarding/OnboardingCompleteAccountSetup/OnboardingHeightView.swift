//
//  OnboardingHeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingHeightView: View {
    @Environment(DependencyContainer.self) private var container

    let gender: Gender
    let dateOfBirth: Date
    @State private var unit: UnitOfLength = .centimeters
    @State private var selectedCentimeters: Int = 175
    @State private var selectedFeet: Int = 5
    @State private var selectedInches: Int = 9
    
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
    
    private var height: Double {
        switch unit {
        case .centimeters:
            return Double(heightInCentimeters)
        case .inches:
            return Double(heightInFeet) + Double(heightInInches) / 12.0
        }
    }
    
    private var preference: LengthUnitPreference {
        switch unit {
        case .centimeters:
            return .centimeters
        case .inches:
            return .inches
        }
    }
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    var body: some View {
        List {
            pickerSection
            if unit == .centimeters {
                metricSection
            } else {
                imperialSection
            }
        }
        .navigationTitle("How tall are you?")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
    }
    
    private var pickerSection: some View {
        Section {
            Picker("Units", selection: $unit) {
                Text("Metric").tag(UnitOfLength.centimeters)
                Text("Imperial").tag(UnitOfLength.inches)
            }
            .pickerStyle(.segmented)
        }
        .removeListRowFormatting()
        
    }
    
    private var metricSection: some View {
        Section {
            Picker("Centimeters", selection: $selectedCentimeters) {
                ForEach((100...250).reversed(), id: \.self) { value in
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
    }
    
    private var imperialSection: some View {
        Section {
            HStack(spacing: 12) {
                Picker("Feet", selection: $selectedFeet) {
                    ForEach((3...8).reversed(), id: \.self) { feet in
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
                    ForEach((0...11).reversed(), id: \.self) { inch in
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
                OnboardingWeightView(gender: gender, dateOfBirth: dateOfBirth, height: height, lengthUnitPreference: preference)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
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
    
}

#Preview {
    NavigationStack {
        OnboardingHeightView(gender: .male, dateOfBirth: Date())
    }
    .previewEnvironment()
}
