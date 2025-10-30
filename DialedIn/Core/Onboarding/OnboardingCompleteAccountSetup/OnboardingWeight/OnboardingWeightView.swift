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
    @Binding var path: [OnboardingPathOption]

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
            Button {
                viewModel.navigateToExerciseFrequency(path: $path)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
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
            ), path: $path
        )
    }
    .previewEnvironment()
}
