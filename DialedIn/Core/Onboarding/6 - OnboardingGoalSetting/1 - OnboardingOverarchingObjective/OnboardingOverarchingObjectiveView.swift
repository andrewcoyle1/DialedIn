//
//  OnboardingOverarchingObjectiveView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 05/10/2025.
//

import SwiftUI

// swiftlint:disable:next type_name
struct OnboardingOverarchingObjectiveViewDelegate {
    var path: Binding<[OnboardingPathOption]>
}

struct OnboardingOverarchingObjectiveView: View {

    @State var viewModel: OnboardingOverarchingObjectiveViewModel

    var delegate: OnboardingOverarchingObjectiveViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView

    var body: some View {
        List {
            objectiveSection
        }
        .navigationTitle("What is your goal?")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            devSettingsView()
        }
        #endif
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
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToNextStep(path: delegate.path)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canContinue)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.onboardingOverarchingObjectiveView(
            delegate: OnboardingOverarchingObjectiveViewDelegate(
                path: $path
            )
        )
    }
    .previewEnvironment()
}
