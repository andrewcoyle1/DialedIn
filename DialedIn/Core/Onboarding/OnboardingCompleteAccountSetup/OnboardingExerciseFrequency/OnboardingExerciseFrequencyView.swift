//
//  OnboardingExerciseFrequencyView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingExerciseFrequencyView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingExerciseFrequencyViewModel
    
    var body: some View {
        List {
            exerciseFrequencySection
        }
        .navigationTitle("Exercise Frequency")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
        .navigationDestination(isPresented: Binding(
            get: {
                if case .activity = viewModel.navigationDestination { return true }
                return false
            },
            set: { if !$0 { viewModel.navigationDestination = nil } }
        )) {
            if case let .activity(gender, dateOfBirth, height, weight, exerciseFrequency, lengthUnitPreference, weightUnitPreference) = viewModel.navigationDestination {
                OnboardingActivityView(
                    viewModel: OnboardingActivityViewModel(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        gender: gender,
                        dateOfBirth: dateOfBirth,
                        height: height,
                        weight: weight,
                        exerciseFrequency: exerciseFrequency,
                        lengthUnitPreference: lengthUnitPreference,
                        weightUnitPreference: weightUnitPreference
                    )
                )
            } else {
                EmptyView()
            }
        }
    }
    
    private var exerciseFrequencySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(ExerciseFrequency.allCases, id: \.self) { frequency in
                    frequencyRow(frequency)
                }
            }
            .removeListRowFormatting()
            .padding(.horizontal)
        } header: {
            Text("How often do you exercise?")
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
                if let frequency = viewModel.selectedFrequency {
                    OnboardingActivityView(
                        viewModel: OnboardingActivityViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            gender: viewModel.gender,
                            dateOfBirth: viewModel.dateOfBirth,
                            height: viewModel.height,
                            weight: viewModel.weight,
                            exerciseFrequency: frequency,
                            lengthUnitPreference: viewModel.lengthUnitPreference,
                            weightUnitPreference: viewModel.weightUnitPreference
                        )
                    )
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canSubmit)
        }
    }
    
    private func frequencyRow(_ frequency: ExerciseFrequency) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(frequency.description)
                    .font(.headline)
            }
            Spacer(minLength: 8)
            Image(systemName: viewModel.selectedFrequency == frequency ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(viewModel.selectedFrequency == frequency ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            viewModel.selectedFrequency = frequency
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationStack {
        OnboardingExerciseFrequencyView(
            viewModel: OnboardingExerciseFrequencyViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                gender: .male,
                dateOfBirth: Date(),
                height: 175,
                weight: 70,
                lengthUnitPreference: .centimeters,
                weightUnitPreference: .kilograms
            )
        )
    }
    .previewEnvironment()
}
