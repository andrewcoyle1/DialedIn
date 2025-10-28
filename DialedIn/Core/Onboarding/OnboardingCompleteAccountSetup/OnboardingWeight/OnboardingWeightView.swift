//
//  OnboardingWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingWeightView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingWeightViewModel

    var body: some View {
        List {
            pickerSection
            
            if viewModel.unit == .kilograms {
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
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(
                viewModel: DevSettingsViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
        }
        #endif
        .navigationDestination(isPresented: Binding(
            get: {
                if case .exerciseFrequency = viewModel.navigationDestination { return true }
                return false
            },
            set: { if !$0 { viewModel.navigationDestination = nil } }
        )) {
            if case let .exerciseFrequency(gender, dateOfBirth, height, weight, lengthUnitPreference, weightUnitPreference) = viewModel.navigationDestination {
                OnboardingExerciseFrequencyView(
                    viewModel: OnboardingExerciseFrequencyViewModel(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        gender: gender,
                        dateOfBirth: dateOfBirth,
                        height: height,
                        weight: weight,
                        lengthUnitPreference: lengthUnitPreference,
                        weightUnitPreference: weightUnitPreference
                    )
                )
            } else {
                EmptyView()
            }
        }
    }
    
    private var pickerSection: some View {
        Section {
            Picker("Units", selection: $viewModel.unit) {
                Text("Metric").tag(UnitOfWeight.kilograms)
                Text("Imperial").tag(UnitOfWeight.pounds)
            }
            .pickerStyle(.segmented)
        }
        .removeListRowFormatting()
    }
    
    private var metricSection: some View {
        Section {
            Picker("Kilograms", selection: $viewModel.selectedKilograms) {
                ForEach((30...200).reversed(), id: \.self) { value in
                    Text("\(value) kg").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: viewModel.selectedKilograms) { _, _ in
                viewModel.updatePoundsFromKilograms()
            }
        } header: {
            Text("Metric")
        }
        .removeListRowFormatting()
    }
    
    private var imperialSection: some View {
        Section {
            Picker("Pounds", selection: $viewModel.selectedPounds) {
                ForEach((66...440).reversed(), id: \.self) { value in
                    Text("\(value) lbs").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: viewModel.selectedPounds) { _, _ in
                viewModel.updateKilogramsFromPounds()
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
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            NavigationLink {
                OnboardingExerciseFrequencyView(
                    viewModel: OnboardingExerciseFrequencyViewModel(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        gender: viewModel.gender,
                        dateOfBirth: viewModel.dateOfBirth,
                        height: viewModel.height,
                        weight: viewModel.weight,
                        lengthUnitPreference: viewModel.lengthUnitPreference,
                        weightUnitPreference: viewModel.preference
                )
                )
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingWeightView(
            viewModel: OnboardingWeightViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                gender: .male,
                dateOfBirth: Date(),
                height: 175,
                lengthUnitPreference: .centimeters
            )
        )
    }
    .previewEnvironment()
}
