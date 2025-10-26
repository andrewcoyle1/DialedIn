//
//  OnboardingTargetWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingTargetWeightView: View {
    @Environment(DependencyContainer.self) private var container

    @Environment(UserManager.self) private var userManager
    let objective: OverarchingObjective
    let isStandaloneMode: Bool
    
    @State private var targetWeight: Double = 0
    @State private var currentWeight: Double = 0
    @State private var weightUnit: WeightUnitPreference = .kilograms
    @State private var selectedKilograms: Int = 0
    @State private var selectedPounds: Int = 0
    @State private var didInitialize: Bool = false
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    init(objective: OverarchingObjective, isStandaloneMode: Bool = false) {
        self.objective = objective
        self.isStandaloneMode = isStandaloneMode
    }
    
    var body: some View {
        List {
            if didInitialize && weightUnit == .kilograms {
                kilogramsSection
            } else if didInitialize {
                poundsSection
            } else {
                loadingSection
            }
        }
        .navigationTitle("Target Weight")
        .onFirstAppear {
            onAppear()
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
        .toolbar {
            toolbarSection
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarSection: some ToolbarContent {
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
                OnboardingWeightRateView(objective: objective, targetWeight: targetWeight, isStandaloneMode: isStandaloneMode)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!canContinue)
        }
    }
    
    private var kilogramsSection: some View {
        Section {
            Picker("Kilograms", selection: $selectedKilograms) {
                ForEach(kilogramRange.reversed(), id: \.self) { value in
                    Text("\(value) kg").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: selectedKilograms) { _, _ in
                updateFromKilograms()
            }
        } header: {
            Text("Metric")
        }
        .removeListRowFormatting()
    }
    
    private var poundsSection: some View {
        Section {
            Picker("Pounds", selection: $selectedPounds) {
                ForEach(poundRange.reversed(), id: \.self) { value in
                    Text("\(value) lbs").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: selectedPounds) { _, _ in
                updateFromPounds()
            }
        } header: {
            Text("Imperial")
        }
        .removeListRowFormatting()
    }
    
    private var loadingSection: some View {
        Section {
            ProgressView()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
        }
        .removeListRowFormatting()
    }
    
    private var canContinue: Bool { 
        targetWeight != 0 && targetWeight != currentWeight 
    }

    // MARK: - Ranges
    private var kilogramRange: ClosedRange<Int> {
        let base = Int((userManager.currentUser?.weightKilograms ?? 0).rounded())
        // Provide sensible global bounds
        let minKg = 30
        let maxKg = 200
        switch objective {
        case .gainWeight:
            let lower = max(minKg, base > 0 ? base : minKg)
            return lower...maxKg
        case .loseWeight:
            let upper = min(maxKg, base > 0 ? base : maxKg)
            return minKg...max(upper, minKg)
        case .maintain:
            // allow +/- 10kg window
            let lower = max(minKg, (base > 0 ? base - 10 : 70))
            let upper = min(maxKg, (base > 0 ? base + 10 : 90))
            return lower...upper
        }
    }

    private var poundRange: ClosedRange<Int> {
        // Convert kg range to lb bounds for parity
        let minLb = 66
        let maxLb = 440
        let baseLb = Int(((userManager.currentUser?.weightKilograms ?? 0) * 2.20462).rounded())
        switch objective {
        case .gainWeight:
            let lower = max(minLb, baseLb > 0 ? baseLb : minLb)
            return lower...maxLb
        case .loseWeight:
            let upper = min(maxLb, baseLb > 0 ? baseLb : maxLb)
            return minLb...max(upper, minLb)
        case .maintain:
            let lower = max(minLb, (baseLb > 0 ? baseLb - 22 : 154 - 22)) // ~10kg
            let upper = min(maxLb, (baseLb > 0 ? baseLb + 22 : 154 + 22))
            return lower...upper
        }
    }

    // MARK: - Updates
    
    private func onAppear() {
        let user = userManager.currentUser
        let fallbackKg = 70
        let currentKg = max(1, Int(user?.weightKilograms ?? 0))
        // Set the user's current weight from the userManager
        currentWeight = user?.weightKilograms ?? Double(fallbackKg)
        weightUnit = user?.weightUnitPreference ?? .kilograms
        // Initialize ranges and selections respecting objective
        switch weightUnit {
        case .kilograms:
            let initial = currentKg > 0 ? currentKg : fallbackKg
            selectedKilograms = clamp(initial: initial, within: kilogramRange)
            updateFromKilograms()
        case .pounds:
            let currentLb = max(1, Int((user?.weightKilograms ?? 0) * 2.20462))
            let fallbackLb = Int((Double(fallbackKg) * 2.20462).rounded())
            let initial = currentLb > 0 ? currentLb : fallbackLb
            selectedPounds = clamp(initial: initial, within: poundRange)
            updateFromPounds()
        }
        didInitialize = true
    }
    private func updateFromKilograms() {
        targetWeight = Double(selectedKilograms)
        selectedPounds = Int((targetWeight * 2.20462).rounded())
    }
    
    private func updateFromPounds() {
        targetWeight = Double(selectedPounds) / 2.20462
        selectedKilograms = Int(targetWeight.rounded())
    }
    
    private func clamp(initial: Int, within range: ClosedRange<Int>) -> Int {
        return min(max(initial, range.lowerBound), range.upperBound)
    }
}

#Preview("Gain Weight") {
    NavigationStack {
        OnboardingTargetWeightView(objective: .gainWeight)
    }
    .previewEnvironment()
}

#Preview("Lose Weight") {
    NavigationStack {
        OnboardingTargetWeightView(objective: .loseWeight)
    }
    .previewEnvironment()
}
