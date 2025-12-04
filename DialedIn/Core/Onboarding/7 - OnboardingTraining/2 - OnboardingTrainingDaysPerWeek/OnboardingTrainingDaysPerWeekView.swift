//
//  OnboardingTrainingDaysPerWeekView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI
import CustomRouting

struct OnboardingTrainingDaysPerWeekView: View {

    @State var presenter: OnboardingTrainingDaysPerWeekPresenter

    var delegate: OnboardingTrainingDaysPerWeekDelegate

    var body: some View {
        List {
            ForEach(Array(1...7), id: \.self) { days in
                Section {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(days) day\(days == 1 ? "" : "s") per week")
                                .font(.headline)
                            Text(daysDescription(for: days))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 8)
                        Image(systemName: presenter.selectedDays == days ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(presenter.selectedDays == days ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { presenter.selectedDays = days }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Training Frequency")
        .toolbar {
            toolbarContent
        }
        .screenAppearAnalytics(name: "TrainingDaysPerWeek")
    }
    
    private func daysDescription(for days: Int) -> String {
        switch days {
        case 1...2:
            return "Light training schedule, great for beginners or active recovery"
        case 3:
            return "Moderate frequency, balanced approach for most people"
        case 4:
            return "Regular training schedule, good for intermediate lifters"
        case 5...6:
            return "High frequency training, for dedicated athletes"
        case 7:
            return "Daily training, requires careful recovery management"
        default:
            return ""
        }
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
                presenter.navigateToSplit(builder: delegate.trainingProgramBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedDays == nil)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingTrainingExperienceView(
            router: router,
            delegate: OnboardingTrainingExperienceDelegate(
                trainingProgramBuilder: TrainingProgramBuilder()
            )
        )
    }
    .previewEnvironment()
}
