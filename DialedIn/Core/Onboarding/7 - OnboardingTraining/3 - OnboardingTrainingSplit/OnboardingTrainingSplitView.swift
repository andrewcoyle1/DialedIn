//
//  OnboardingTrainingSplitView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingTrainingSplitView: View {

    @State var presenter: OnboardingTrainingSplitPresenter

    var delegate: OnboardingTrainingSplitDelegate

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
                        Image(systemName: presenter.selectedSplit == split ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(presenter.selectedSplit == split ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { presenter.selectedSplit = split }
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
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.navigateToSchedule(builder: delegate.trainingProgramBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedSplit == nil)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingTrainingSplitView(
            router: router,
            delegate: OnboardingTrainingSplitDelegate(
                trainingProgramBuilder: TrainingProgramBuilder()
            )
        )
    }
    .previewEnvironment()
}
