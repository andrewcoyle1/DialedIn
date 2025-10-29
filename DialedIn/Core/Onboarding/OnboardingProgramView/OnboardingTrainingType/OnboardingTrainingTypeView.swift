//
//  OnboardingTrainingTypeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingTrainingTypeView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingTrainingTypeViewModel

    var body: some View {
        List {
            ForEach(TrainingType.allCases) { type in
                Section {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type.description)
                                .font(.headline)
                            Text(type.detailedDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: viewModel.selectedTrainingType == type ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(viewModel.selectedTrainingType == type ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.selectedTrainingType = type }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Training Focus")
        .navigationBarTitleDisplayMode(.large)
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
        .navigationDestination(isPresented: Binding(
            get: {
                if case .calorieDistribution = viewModel.navigationDestination { return true }
                return false
            },
            set: { if !$0 { viewModel.navigationDestination = nil } }
        )) {
            Group {
                if let selectedTrainingType = viewModel.selectedTrainingType {
                    OnboardingCalorieDistributionView(
                        viewModel: OnboardingCalorieDistributionViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            preferredDiet: viewModel.preferredDiet,
                            calorieFloor: viewModel.calorieFloor,
                            trainingType: selectedTrainingType
                        )
                    )
                }
            }
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
                if let trainingType = viewModel.selectedTrainingType {
                    OnboardingCalorieDistributionView(
                        viewModel: OnboardingCalorieDistributionViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            preferredDiet: viewModel.preferredDiet,
                            calorieFloor: viewModel.calorieFloor,
                            trainingType: trainingType
                        )
                    )
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedTrainingType == nil)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingTrainingTypeView(
            viewModel: OnboardingTrainingTypeViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                preferredDiet: .balanced,
                calorieFloor: .standard
            )
        )
    }
    .previewEnvironment()
}
