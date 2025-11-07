//
//  OnboardingTrainingExperienceView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI

struct OnboardingTrainingExperienceView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingTrainingExperienceViewModel
    @Binding var path: [OnboardingPathOption]
    var trainingProgramBuilder: TrainingProgramBuilder

    var body: some View {
        List {
            listContent
        }
        .navigationTitle("Training Experience")
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(
                viewModel: DevSettingsViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
        }
        #endif
        .screenAppearAnalytics(name: "TrainingExperience")
    }
    
    private func experienceDescription(for level: DifficultyLevel) -> String {
        switch level {
        case .beginner:
            return "New to structured training or returning after a long break"
        case .intermediate:
            return "Regular training experience, comfortable with basic movements"
        case .advanced:
            return "Years of training experience, ready for complex programs"
        }
    }

    private var listContent: some View {
        ForEach(DifficultyLevel.allCases) { level in
            Section {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(level.description)
                            .font(.headline)
                        Text(experienceDescription(for: level))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: viewModel.selectedLevel == level ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(viewModel.selectedLevel == level ? .accent : .secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture { viewModel.selectedLevel = level }
                .padding(.vertical)
            }
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
                viewModel.navigateToDaysPerWeek(path: $path, builder: trainingProgramBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.selectedLevel == nil)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        OnboardingTrainingExperienceView(
            viewModel: OnboardingTrainingExperienceViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ),
            path: $path,
            trainingProgramBuilder: TrainingProgramBuilder()
        )
    }
    .previewEnvironment()
}
