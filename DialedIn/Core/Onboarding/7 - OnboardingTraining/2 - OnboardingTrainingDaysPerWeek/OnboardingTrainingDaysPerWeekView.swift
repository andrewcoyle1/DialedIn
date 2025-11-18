//
//  OnboardingTrainingDaysPerWeekView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

struct OnboardingTrainingDaysPerWeekViewDelegate {
    var path: Binding<[OnboardingPathOption]>
    var trainingProgramBuilder: TrainingProgramBuilder
}

struct OnboardingTrainingDaysPerWeekView: View {

    @State var viewModel: OnboardingTrainingDaysPerWeekViewModel

    var delegate: OnboardingTrainingDaysPerWeekViewDelegate

    @ViewBuilder var devSettingsView: () -> AnyView

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
                        Image(systemName: viewModel.selectedDays == days ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(viewModel.selectedDays == days ? .accent : .secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.selectedDays = days }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Training Frequency")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            devSettingsView()
        }
        #endif
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
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToSplit(path: delegate.path, builder: delegate.trainingProgramBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedDays == nil)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack {
        builder.onboardingTrainingExperienceView(
            delegate: OnboardingTrainingExperienceViewDelegate(
                path: $path,
                trainingProgramBuilder: TrainingProgramBuilder()
            )
        )
    }
    .previewEnvironment()
}
