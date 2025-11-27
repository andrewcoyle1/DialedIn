//
//  OnboardingProteinIntakeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingProteinIntakeView: View {

    @State var presenter: OnboardingProteinIntakePresenter

    var delegate: OnboardingProteinIntakeDelegate

    var body: some View {
        List {
            if let difficulty = presenter.trainingDifficulty {
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
        .showModal(showModal: $presenter.showModal) {
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
                    Image(systemName: presenter.selectedProteinIntake == intake ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(presenter.selectedProteinIntake == intake ? .accent : .secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture { presenter.selectedProteinIntake = intake }
                .padding(.vertical)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.navigate(dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedProteinIntake == nil)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingProteinIntakeView(
            router: router,
            delegate: OnboardingProteinIntakeDelegate(
                dietPlanBuilder: .proteinIntakeMock
            )
        )
    }
    .previewEnvironment()
}
