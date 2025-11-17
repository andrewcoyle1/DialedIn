//
//  OnboardingTrainingTypeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingTrainingTypeViewDelegate {
    var path: Binding<[OnboardingPathOption]>
    let dietPlanBuilder: DietPlanBuilder
}

struct OnboardingTrainingTypeView: View {
    @Environment(CoreBuilder.self) private var builder
    @State var viewModel: OnboardingTrainingTypeViewModel
    var delegate: OnboardingTrainingTypeViewDelegate

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
            builder.devSettingsView()
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
            Button {
                viewModel.navigateToCalorieDistribution(path: delegate.path, dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedTrainingType == nil)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.onboardingTrainingTypeView(
            delegate: OnboardingTrainingTypeViewDelegate(
                path: $path,
                dietPlanBuilder: .trainingTypeMock
            )
        )
    }
    .previewEnvironment()
}
