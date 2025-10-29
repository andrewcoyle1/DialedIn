//
//  OnboardingCardioFitnessView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingCardioFitnessView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingCardioFitnessViewModel
    
    var body: some View {
        List {
            cardioFitnessSection
        }
        .navigationTitle("Cardio Fitness")
        .toolbar {
            toolbarContent
        }
        .showCustomAlert(alert: $viewModel.showAlert)
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
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
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
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            NavigationLink {
                if let cardioFitnessLevel = viewModel.selectedCardioFitness {
                    OnboardingExpenditureView(
                        viewModel: OnboardingExpenditureViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            gender: viewModel.gender,
                            dateOfBirth: viewModel.dateOfBirth,
                            height: viewModel.height,
                            weight: viewModel.weight,
                            exerciseFrequency: viewModel.exerciseFrequency,
                            activityLevel: viewModel.activityLevel,
                            lengthUnitPreference: viewModel.lengthUnitPreference,
                            weightUnitPreference: viewModel.weightUnitPreference,
                            selectedCardioFitness: cardioFitnessLevel
                        )
                    )
                }
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
    NavigationStack {
        OnboardingCardioFitnessView(
            viewModel: OnboardingCardioFitnessViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                gender: .male,
                dateOfBirth: Date(),
                height: 180,
                weight: 75,
                exerciseFrequency: .threeToFour,
                activityLevel: .moderate,
                lengthUnitPreference: .centimeters,
                weightUnitPreference: .kilograms
            )
        )
    }
    .previewEnvironment()
}
