//
//  OnboardingPreferredDietView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingPreferredDietView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingPreferredDietViewModel
    
    var body: some View {
        List {
            ForEach(PreferredDiet.allCases) { diet in
                Section {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(diet.description)
                                .font(.headline)
                            Text(diet.detailedDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: viewModel.selectedDiet == diet ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(viewModel.selectedDiet == diet ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.selectedDiet = diet }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Choose your diet")
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
                if let diet = viewModel.selectedDiet {
                    OnboardingCalorieFloorView(
                        viewModel: OnboardingCalorieFloorViewModel(
                            interactor: CoreInteractor(
                                container: container
                            ),
                            preferredDiet: diet
                        )
                    )
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedDiet == nil)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingPreferredDietView(
            viewModel: OnboardingPreferredDietViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            )
        )
    }
    .previewEnvironment()
}
