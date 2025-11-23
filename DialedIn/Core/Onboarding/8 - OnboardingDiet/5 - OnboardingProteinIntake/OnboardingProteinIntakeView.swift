//
//  OnboardingProteinIntakeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingProteinIntakeViewDelegate {
    let dietPlanBuilder: DietPlanBuilder
}

struct OnboardingProteinIntakeView: View {

    @State var viewModel: OnboardingProteinIntakeViewModel

    var delegate: OnboardingProteinIntakeViewDelegate

    var body: some View {
        List {
            if let difficulty = viewModel.trainingDifficulty {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("You selected \(difficulty.description) training. We recommend higher protein for recovery.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .removeListRowFormatting()
                    .padding(.horizontal)
                }
            }
            
            pickerSection
        }
        .navigationTitle("Protein Intake")
        .toolbar {
            toolbarContent
        }
        .showModal(showModal: $viewModel.showModal) {
            ProgressView()
                .tint(Color.white)
        }
    }
    
    private var pickerSection: some View {
        ForEach(ProteinIntake.allCases) { intake in
            Section {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(intake.description)
                            .font(.headline)
                        Text(intake.detailedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: viewModel.selectedProteinIntake == intake ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(viewModel.selectedProteinIntake == intake ? .accent : .secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture { viewModel.selectedProteinIntake = intake }
                .padding(.vertical)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
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
                viewModel.navigate(dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedProteinIntake == nil)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingProteinIntakeView(
            router: router,
            delegate: OnboardingProteinIntakeViewDelegate(
                dietPlanBuilder: .proteinIntakeMock
            )
        )
    }
    .previewEnvironment()
}
