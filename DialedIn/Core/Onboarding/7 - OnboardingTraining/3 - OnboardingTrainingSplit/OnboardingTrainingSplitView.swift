//
//  OnboardingTrainingSplitView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI
import CustomRouting

struct OnboardingTrainingSplitViewDelegate {
    var trainingProgramBuilder: TrainingProgramBuilder
}

struct OnboardingTrainingSplitView: View {

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
        .screenAppearAnalytics(name: "TrainingSplit")
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
                viewModel.navigateToSchedule(builder: delegate.trainingProgramBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedSplit == nil)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingTrainingSplitView(
            router: router,
            delegate: OnboardingTrainingSplitViewDelegate(
                trainingProgramBuilder: TrainingProgramBuilder()
            )
        )
    }
    .previewEnvironment()
}
