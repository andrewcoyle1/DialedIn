//
//  OnboardingTargetWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingTargetWeightViewDelegate {
    var weightGoalBuilder: WeightGoalBuilder
}

struct OnboardingTargetWeightView: View {

    @State var viewModel: OnboardingTargetWeightViewModel

    var delegate: OnboardingTargetWeightViewDelegate

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
        .toolbar {
            toolbarSection
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarSection: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToWeightRate(weightGoalBuilder: delegate.weightGoalBuilder)
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
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingTargetWeightView(
            router: router,
            delegate: OnboardingTargetWeightViewDelegate(weightGoalBuilder: .targetWeightMock)
        )
    }
    .previewEnvironment()
}

#Preview("Lose Weight") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingTargetWeightView(
            router: router,
            delegate: OnboardingTargetWeightViewDelegate(weightGoalBuilder: .targetWeightMock)
        )
    }
    .previewEnvironment()
}
