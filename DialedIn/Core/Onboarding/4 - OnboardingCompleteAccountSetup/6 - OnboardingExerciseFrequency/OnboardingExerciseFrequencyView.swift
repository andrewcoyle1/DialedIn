//
//  OnboardingExerciseFrequencyView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingExerciseFrequencyView: View {

    @State var presenter: OnboardingExerciseFrequencyPresenter

    var delegate: OnboardingExerciseFrequencyDelegate

    var body: some View {
        List {
            exerciseFrequencySection
        }
        .navigationTitle("Exercise Frequency")
        .toolbar {
            toolbarContent
        }
    }
    
    private var exerciseFrequencySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(ExerciseFrequency.allCases, id: \.self) { frequency in
                    frequencyRow(frequency)
                }
            }
            .removeListRowFormatting()
            .padding(.horizontal)
        } header: {
            Text("How often do you exercise?")
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
                presenter.navigateToOnboardingActivity(userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canSubmit)
        }
    }
    
    private func frequencyRow(_ frequency: ExerciseFrequency) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(frequency.description)
                    .font(.headline)
            }
            Spacer(minLength: 8)
            Image(systemName: presenter.selectedFrequency == frequency ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(presenter.selectedFrequency == frequency ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            presenter.selectedFrequency = frequency
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

extension OnbBuilder {
    func onboardingExerciseFrequencyView(router: AnyRouter, delegate: OnboardingExerciseFrequencyDelegate) -> some View {
        OnboardingExerciseFrequencyView(
            presenter: OnboardingExerciseFrequencyPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension OnbRouter {
    func showOnboardingExerciseFrequencyView(delegate: OnboardingExerciseFrequencyDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingExerciseFrequencyView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container))
    RouterView { router in
        builder.onboardingExerciseFrequencyView(
            router: router,
            delegate: OnboardingExerciseFrequencyDelegate(userModelBuilder: UserModelBuilder.exerciseFrequencyMock)
        )
    }
    .previewEnvironment()
}
