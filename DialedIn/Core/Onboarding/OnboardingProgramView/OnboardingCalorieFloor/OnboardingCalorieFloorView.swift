//
//  OnboardingCalorieFloorView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingCalorieFloorView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingCalorieFloorViewModel

    var body: some View {
        List {
            ForEach(CalorieFloor.allCases) { type in
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
                        Image(systemName: viewModel.selectedFloor == type ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(viewModel.selectedFloor == type ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.selectedFloor = type }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Calorie floor")
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
                if case .trainingType = viewModel.navigationDestination { return true }
                return false
            },
            set: { if !$0 { viewModel.navigationDestination = nil } }
        )) {
            Group {
                if let selectedFloor = viewModel.selectedFloor {
                    OnboardingTrainingTypeView(
                        viewModel: OnboardingTrainingTypeViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                        preferredDiet: viewModel.preferredDiet,
                        calorieFloor: selectedFloor
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
                if let floor = viewModel.selectedFloor {
                    OnboardingTrainingTypeView(
                        viewModel: OnboardingTrainingTypeViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            preferredDiet: viewModel.preferredDiet,
                            calorieFloor: floor
                        )
                    )
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedFloor == nil)
        }
    }
}

enum CalorieFloor: String, CaseIterable, Identifiable {
    case standard
    case low
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .standard:
            return "Standard Floor (Recommended)"
        case .low:
            return "Low Floor"
        }
    }
    
    var detailedDescription: String {
        switch self {
        case .standard:
            return "Your recommendations will never go below 1200 calories per day, even if your TDEE is lower."
        case .low:
            return "Your recommendations will never go below 800 calories per day. Proceed with caution."
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingCalorieFloorView(
            viewModel: OnboardingCalorieFloorViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                preferredDiet: .balanced
            )
        )
    }
    .previewEnvironment()
}
