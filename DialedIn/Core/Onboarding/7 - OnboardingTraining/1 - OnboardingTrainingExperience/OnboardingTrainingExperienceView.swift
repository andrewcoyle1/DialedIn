//
//  OnboardingTrainingExperienceView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingTrainingExperienceView: View {

    @State var presenter: OnboardingTrainingExperiencePresenter

    var delegate: OnboardingTrainingExperienceDelegate

    var body: some View {
        List {
            listContent
        }
        .navigationTitle("Training Experience")
        .toolbar {
            toolbarContent
        }
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
                    Image(systemName: presenter.selectedLevel == level ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(presenter.selectedLevel == level ? .accent : .secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture { presenter.selectedLevel = level }
                .padding(.vertical)
            }
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
                presenter.navigateToDaysPerWeek(builder: delegate.trainingProgramBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedLevel == nil)
        }
    }
}

extension OnbBuilder {
    func onboardingTrainingExperienceView(router: AnyRouter, delegate: OnboardingTrainingExperienceDelegate) -> some View {
        OnboardingTrainingExperienceView(
            presenter: OnboardingTrainingExperiencePresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension OnbRouter {
    func showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingExperienceView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
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
