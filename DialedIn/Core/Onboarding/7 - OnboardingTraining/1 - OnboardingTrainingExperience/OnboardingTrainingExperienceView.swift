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
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
    }
    
    private var listContent: some View {
        Group {
            Text("Add content here")
            ForEach(TrainingExperience.allCases, id: \.self) { level in
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
                presenter.navigateToDaysPerWeek(delegate: delegate)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedLevel == nil)
        }
    }
    
    private func experienceDescription(for level: TrainingExperience) -> String {
        switch level {
        case .beginner:
            return "New to structured training or returning after a long break"
        case .intermediate:
            return "Regular training experience, comfortable with basic movements"
        case .advanced:
            return "Years of training experience, ready for complex programs"
        }
    }
}

extension CoreBuilder {
    func onboardingTrainingExperienceView(router: AnyRouter, delegate: OnboardingTrainingExperienceDelegate) -> some View {
        OnboardingTrainingExperienceView(
            presenter: OnboardingTrainingExperiencePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showOnboardingTrainingExperienceView(delegate: OnboardingTrainingExperienceDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingExperienceView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingTrainingExperienceView(
            router: router,
            delegate: OnboardingTrainingExperienceDelegate()
        )
    }
    
}
