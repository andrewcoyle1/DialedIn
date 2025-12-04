//
//  OnboardingTrainingScheduleView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingTrainingScheduleView: View {

    @State var presenter: OnboardingTrainingSchedulePresenter

    var delegate: OnboardingTrainingScheduleDelegate

    private let weekdays = [
        (1, "Sunday"),
        (2, "Monday"),
        (3, "Tuesday"),
        (4, "Wednesday"),
        (5, "Thursday"),
        (6, "Friday"),
        (7, "Saturday")
    ]

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select the days you want to train each week.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let targetDays = delegate.trainingProgramBuilder.targetDaysPerWeek {
                        Text("You selected \(targetDays) day\(targetDays == 1 ? "" : "s") per week.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .removeListRowFormatting()
                .padding(.horizontal)
            }
            
            ForEach(weekdays, id: \.0) { dayNumber, dayName in
                Section {
                    HStack(alignment: .center, spacing: 12) {
                        Text(dayName)
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { presenter.selectedDays.contains(dayNumber) },
                            set: { isOn in
                                if isOn {
                                    presenter.selectedDays.insert(dayNumber)
                                } else {
                                    presenter.selectedDays.remove(dayNumber)
                                }
                            }
                        ))
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Training Schedule")
        .toolbar {
            toolbarContent
        }
        .screenAppearAnalytics(name: "TrainingSchedule")
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
                presenter.navigateToEquipment(builder: delegate.trainingProgramBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedDays.isEmpty)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingTrainingScheduleView(
            router: router, 
            delegate: OnboardingTrainingScheduleDelegate(
                trainingProgramBuilder: TrainingProgramBuilder(targetDaysPerWeek: 3)
            )
        )
    }
    .previewEnvironment()
}
