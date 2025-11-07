//
//  OnboardingTrainingEquipmentView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

struct OnboardingTrainingEquipmentView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingTrainingEquipmentViewModel
    @Binding var path: [OnboardingPathOption]
    var trainingProgramBuilder: TrainingProgramBuilder

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select all equipment you have access to. This helps us recommend the best program for you.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .removeListRowFormatting()
                .padding(.horizontal)
            }
            
            ForEach(EquipmentType.allCases) { equipment in
                Section {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: equipment.systemImage)
                            .foregroundStyle(.accent)
                            .frame(width: 24)
                        Text(equipment.description)
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { viewModel.selectedEquipment.contains(equipment) },
                            set: { isOn in
                                if isOn {
                                    viewModel.selectedEquipment.insert(equipment)
                                } else {
                                    viewModel.selectedEquipment.remove(equipment)
                                }
                            }
                        ))
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Available Equipment")
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
        .screenAppearAnalytics(name: "TrainingEquipment")
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
            Button {
                viewModel.navigateToReview(path: $path, builder: trainingProgramBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedEquipment.isEmpty)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        OnboardingTrainingEquipmentView(
            viewModel: OnboardingTrainingEquipmentViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ),
            path: $path,
            trainingProgramBuilder: TrainingProgramBuilder()
        )
    }
    .previewEnvironment()
}
