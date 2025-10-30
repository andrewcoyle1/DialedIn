//
//  OnboardingTargetWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingTargetWeightView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingTargetWeightViewModel
    @Binding var path: [OnboardingPathOption]

    var body: some View {
        List {
            if viewModel.didInitialize && viewModel.weightUnit == .kilograms {
                kilogramsSection
            } else if viewModel.didInitialize {
                poundsSection
            } else {
                loadingSection
            }
        }
        .navigationTitle("Target Weight")
        .onFirstAppear {
            viewModel.onAppear()
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
        .toolbar {
            toolbarSection
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarSection: some ToolbarContent {
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
                viewModel.navigateToWeightRate(path: $path)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canContinue)
        }
    }
    
    private var kilogramsSection: some View {
        Section {
            Picker("Kilograms", selection: $viewModel.selectedKilograms) {
                ForEach(viewModel.kilogramRange.reversed(), id: \.self) { value in
                    Text("\(value) kg").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: viewModel.selectedKilograms) { _, _ in
                viewModel.updateFromKilograms()
            }
        } header: {
            Text("Metric")
        }
        .removeListRowFormatting()
    }
    
    private var poundsSection: some View {
        Section {
            Picker("Pounds", selection: $viewModel.selectedPounds) {
                ForEach(viewModel.poundRange.reversed(), id: \.self) { value in
                    Text("\(value) lbs").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .clipped()
            .onChange(of: viewModel.selectedPounds) { _, _ in
                viewModel.updateFromPounds()
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
}

#Preview("Gain Weight") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        OnboardingTargetWeightView(
            viewModel: OnboardingTargetWeightViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                objective: .gainWeight
            ), path: $path
        )
    }
    .previewEnvironment()
}

#Preview("Lose Weight") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        OnboardingTargetWeightView(
            viewModel: OnboardingTargetWeightViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                objective: .loseWeight
            ), path: $path
        )
    }
    .previewEnvironment()
}
