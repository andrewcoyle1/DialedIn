//
//  OnboardingWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingWeightView: View {
    @Environment(DependencyContainer.self) private var container

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
    
    private var weight: Double {
        switch unit {
        case .kilograms:
            Double(selectedKilograms)
        case .pounds:
            Double(selectedPounds) * 0.453592
        }
    }
    
    private var preference: WeightUnitPreference {
        switch unit {
        case .kilograms:
            return .kilograms
        case .pounds:
            return .pounds
        }
    }
    
    enum UnitOfWeight {
        case kilograms
        case pounds
    }
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    var body: some View {
        List {
            pickerSection
            
            if unit == .kilograms {
                metricSection
            } else {
                imperialSection
            }
        }
        .navigationTitle("What's your weight?")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
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
    
    private var pickerSection: some View {
        Section {
            Picker("Units", selection: $unit) {
                Text("Metric").tag(UnitOfWeight.kilograms)
                Text("Imperial").tag(UnitOfWeight.pounds)
            }
            .pickerStyle(.segmented)
        }
        .removeListRowFormatting()
    }
    
    private var metricSection: some View {
        Section {
            Picker("Kilograms", selection: $selectedKilograms) {
                ForEach((30...200).reversed(), id: \.self) { value in
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
    }
    
    private var imperialSection: some View {
        Section {
            Picker("Pounds", selection: $selectedPounds) {
                ForEach((66...440).reversed(), id: \.self) { value in
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
                OnboardingExerciseFrequencyView(gender: gender, dateOfBirth: dateOfBirth, height: height, weight: weight, lengthUnitPreference: lengthUnitPreference, weightUnitPreference: preference)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
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
}

#Preview {
    NavigationStack {
        OnboardingWeightView(gender: .male, dateOfBirth: Date(), height: 175, lengthUnitPreference: .centimeters)
    }
    .previewEnvironment()
}
