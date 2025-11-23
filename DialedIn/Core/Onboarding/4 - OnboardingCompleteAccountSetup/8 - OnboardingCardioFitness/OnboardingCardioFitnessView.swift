//
//  OnboardingCardioFitnessView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingCardioFitnessViewDelegate {
    var userModelBuilder: UserModelBuilder
}

struct OnboardingCardioFitnessView: View {

    @State var viewModel: OnboardingCardioFitnessViewModel

    var delegate: OnboardingCardioFitnessViewDelegate

    var body: some View {
        List {
            cardioFitnessSection
        }
        .navigationTitle("Cardio Fitness")
        .toolbar {
            toolbarContent
        }
        .showModal(showModal: $viewModel.isSaving) {
            ProgressView()
                .tint(.white)
        }
        .onDisappear {
            // Clean up any ongoing tasks and reset loading states
            viewModel.currentSaveTask?.cancel()
            viewModel.currentSaveTask = nil
            viewModel.isSaving = false
        }
    }
    
    private var cardioFitnessSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                Text("How would you rate your cardiovascular fitness?")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                Text("Consider your ability to maintain sustained cardio activities like running, cycling, or swimming.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                ForEach(CardioFitnessLevel.allCases, id: \.self) { level in
                    cardioFitnessRow(level)
                }
            }
            .removeListRowFormatting()
            .padding(.horizontal)
        } header: {
            Text("Cardiovascular Fitness")
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
                viewModel.navigateToExpenditure(userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!viewModel.canSubmit)
            .buttonStyle(.glassProminent)
        }
    }
    
    private func cardioFitnessRow(_ level: CardioFitnessLevel) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(level.description)
                    .font(.headline)
                Text(level.detailDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: viewModel.selectedCardioFitness == level ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(viewModel.selectedCardioFitness == level ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            viewModel.selectedCardioFitness = level
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview("Default - Ready to submit") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingCardioFitnessView(
            router: router,
            delegate: OnboardingCardioFitnessViewDelegate(userModelBuilder: UserModelBuilder.cardioFitnessMock)
        )
    }
    .previewEnvironment()
}
