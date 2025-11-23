//
//  OnboardingTrainingScheduleView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI
import CustomRouting

struct OnboardingTrainingScheduleViewDelegate {
    var trainingProgramBuilder: TrainingProgramBuilder
}

struct OnboardingTrainingScheduleView: View {

    @State var viewModel: OnboardingTrainingScheduleViewModel

    var delegate: OnboardingTrainingScheduleViewDelegate

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
                            get: { viewModel.selectedDays.contains(dayNumber) },
                            set: { isOn in
                                if isOn {
                                    viewModel.selectedDays.insert(dayNumber)
                                } else {
                                    viewModel.selectedDays.remove(dayNumber)
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
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToEquipment(builder: delegate.trainingProgramBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedDays.isEmpty)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingTrainingScheduleView(
            router: router, 
            delegate: OnboardingTrainingScheduleViewDelegate(
                trainingProgramBuilder: TrainingProgramBuilder(targetDaysPerWeek: 3)
            )
        )
    }
    .previewEnvironment()
}
