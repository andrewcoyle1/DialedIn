//
//  ExerciseFrequencyView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct ExerciseFrequencyDelegate {
    let gender: Gender
    let dateOfBirth: Date
    let heightInCentimetres: Double
    let lengthUnitPreference: LengthUnitPreference
    let weightInKilograms: Double
    let weightUnitPreference: WeightUnitPreference
    
    init(delegate: WeightDelegate, weightInKilograms: Double, weightUnitPreference: WeightUnitPreference) {
        self.gender = delegate.gender
        self.dateOfBirth = delegate.dateOfBirth
        self.heightInCentimetres = delegate.heightInCentimeters
        self.lengthUnitPreference = delegate.lengthUnitPreference
        self.weightInKilograms = weightInKilograms
        self.weightUnitPreference = weightUnitPreference
    }
    
    static var mock: Self {
        Self(delegate: .mock, weightInKilograms: 82, weightUnitPreference: .kilograms)
    }
}

struct ExerciseFrequencyView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: ExerciseFrequencyPresenter

    var delegate: ExerciseFrequencyDelegate

    var body: some View {
        List {
            exerciseFrequencySection
        }
        .navigationTitle("Exercise Frequency")
        #if DEBUG || MOCK
        .toolbar {
            toolbarContent
        }
        #endif
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.onContinuePressed(delegate: delegate)
            } label: {
                Text("Continue")
            }
            .accessibilityIdentifier("Continue")
            .disabled(!presenter.canSubmit)
        }
    }
    
    private var exerciseFrequencySection: some View {
        Section {
            ForEach(ExerciseFrequency.allCases, id: \.self) { frequency in
                frequencyRow(frequency)
            }
            .removeListRowFormatting()
        } header: {
            Text("How often do you exercise?")
        }
    }
    
    #if DEBUG || MOCK
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
    }
    #endif
    
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
        .padding()
        .background(colorScheme.backgroundPrimary)
        .anyButton(.press) {
            presenter.selectedFrequency = frequency
        }
    }
}

extension CoreBuilder {
    func exerciseFrequencyView(router: AnyRouter, delegate: ExerciseFrequencyDelegate) -> some View {
        ExerciseFrequencyView(
            presenter: ExerciseFrequencyPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showExerciseFrequencyView(delegate: ExerciseFrequencyDelegate) {
        router.showScreen(.push) { router in
            builder.exerciseFrequencyView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.exerciseFrequencyView(
            router: router,
            delegate: .mock
        )
    }
    
}
