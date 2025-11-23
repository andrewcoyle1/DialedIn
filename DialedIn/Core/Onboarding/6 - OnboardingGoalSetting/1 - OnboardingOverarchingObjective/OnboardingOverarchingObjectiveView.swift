//
//  OnboardingOverarchingObjectiveView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingOverarchingObjectiveView: View {

    @State var viewModel: OnboardingOverarchingObjectiveViewModel

    var body: some View {
        List {
            objectiveSection
        }
        .navigationTitle("What is your goal?")
        .toolbar {
            toolbarContent
        }
    }
    
    private var objectiveSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(OverarchingObjective.allCases, id: \.self) { objective in
                    objectiveRow(objective)
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Choose one")
        }
    }
    
    private func objectiveRow(_ objective: OverarchingObjective) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(objective.description)
                    .font(.headline)
                Text(objective.detailedDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: viewModel.selectedObjective == objective ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(viewModel.selectedObjective == objective ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            viewModel.selectedObjective = objective
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
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
                viewModel.navigateToNextStep()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canContinue)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingOverarchingObjectiveView(router: router)
    }
    .previewEnvironment()
}
