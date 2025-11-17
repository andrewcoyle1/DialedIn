//
//  OnboardingTrainingSplitView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

struct OnboardingTrainingSplitViewDelegate {
    var path: Binding<[OnboardingPathOption]>
    var trainingProgramBuilder: TrainingProgramBuilder
}

struct OnboardingTrainingSplitView: View {

    @Environment(CoreBuilder.self) private var builder

    @State var viewModel: OnboardingTrainingSplitViewModel

    var delegate: OnboardingTrainingSplitViewDelegate

    var body: some View {
        List {
            ForEach(TrainingSplitType.allCases) { split in
                Section {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(split.description)
                                .font(.headline)
                            Text(split.detailedDescription)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("Typically \(split.typicalDaysPerWeek) days per week")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: viewModel.selectedSplit == split ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(viewModel.selectedSplit == split ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.selectedSplit = split }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Training Split")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            builder.devSettingsView()
        }
        #endif
        .screenAppearAnalytics(name: "TrainingSplit")
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
                viewModel.navigateToSchedule(path: delegate.path, builder: delegate.trainingProgramBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedSplit == nil)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.onboardingTrainingSplitView(
            delegate: OnboardingTrainingSplitViewDelegate(
                path: $path,
                trainingProgramBuilder: TrainingProgramBuilder()
            )
        )
    }
    .previewEnvironment()
}
