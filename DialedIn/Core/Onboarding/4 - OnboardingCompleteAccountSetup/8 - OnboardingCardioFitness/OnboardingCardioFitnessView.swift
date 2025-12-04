//
//  OnboardingCardioFitnessView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingCardioFitnessView: View {

    @State var presenter: OnboardingCardioFitnessPresenter

    var delegate: OnboardingCardioFitnessDelegate

    var body: some View {
        List {
            cardioFitnessSection
        }
        .navigationTitle("Cardio Fitness")
        .toolbar {
            toolbarContent
        }
        .showModal(showModal: $presenter.isSaving) {
            ProgressView()
                .tint(.white)
        }
        .onDisappear {
            // Clean up any ongoing tasks and reset loading states
            presenter.currentSaveTask?.cancel()
            presenter.currentSaveTask = nil
            presenter.isSaving = false
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
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.navigateToExpenditure(userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!presenter.canSubmit)
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
            Image(systemName: presenter.selectedCardioFitness == level ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(presenter.selectedCardioFitness == level ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            presenter.selectedCardioFitness = level
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview("Default - Ready to submit") {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingCardioFitnessView(
            router: router,
            delegate: OnboardingCardioFitnessDelegate(userModelBuilder: UserModelBuilder.cardioFitnessMock)
        )
    }
    .previewEnvironment()
}
