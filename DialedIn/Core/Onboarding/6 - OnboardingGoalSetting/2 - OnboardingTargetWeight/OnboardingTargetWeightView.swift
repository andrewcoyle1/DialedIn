//
//  OnboardingTargetWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

struct OnboardingTargetWeightViewDelegate {
    var path: Binding<[OnboardingPathOption]>
    var weightGoalBuilder: WeightGoalBuilder
}

struct OnboardingTargetWeightView: View {

    @State var viewModel: OnboardingTargetWeightViewModel

    var delegate: OnboardingTargetWeightViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView

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
            viewModel.onAppear(weightGoalBuilder: delegate.weightGoalBuilder)
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            devSettingsView()
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
                viewModel.navigateToWeightRate(path: delegate.path, weightGoalBuilder: delegate.weightGoalBuilder)
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
                ForEach(viewModel.kilogramRange(weightGoalBuilder: delegate.weightGoalBuilder).reversed(), id: \.self) { value in
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
                ForEach(viewModel.poundRange(weightGoalBuilder: delegate.weightGoalBuilder).reversed(), id: \.self) { value in
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.onboardingTargetWeightView(
            delegate: OnboardingTargetWeightViewDelegate(
                path: $path,
                weightGoalBuilder: .targetWeightMock
            )
        )
    }
    .previewEnvironment()
}

#Preview("Lose Weight") {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.onboardingTargetWeightView(
            delegate: OnboardingTargetWeightViewDelegate(
                path: $path,
                weightGoalBuilder: .targetWeightMock
            )
        )
    }
    .previewEnvironment()
}
