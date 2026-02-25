//
//  CardioFitnessView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct CardioFitnessDelegate {
    let gender: Gender
    let dateOfBirth: Date
    let heightInCentimetres: Double
    let lengthUnitPreference: LengthUnitPreference
    let weightInKilograms: Double
    let weightUnitPreference: WeightUnitPreference
    let exerciseFrequency: ExerciseFrequency
    let activityLevel: ActivityLevel
    
    init(delegate: ActivityDelegate, activityLevel: ActivityLevel) {
        self.gender = delegate.gender
        self.dateOfBirth = delegate.dateOfBirth
        self.heightInCentimetres = delegate.heightInCentimetres
        self.lengthUnitPreference = delegate.lengthUnitPreference
        self.weightInKilograms = delegate.weightInKilograms
        self.weightUnitPreference = delegate.weightUnitPreference
        self.exerciseFrequency = delegate.exerciseFrequency
        self.activityLevel = activityLevel
    }
    
    static var mock: Self {
        Self(delegate: .mock, activityLevel: .active)
    }

}

struct CardioFitnessView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: CardioFitnessPresenter

    var delegate: CardioFitnessDelegate

    var body: some View {
        List {
            cardioFitnessSection
        }
        .navigationTitle("Cardio Fitness")
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
    
    private var cardioFitnessSection: some View {
        Section {
            ForEach(CardioFitnessLevel.allCases, id: \.self) { level in
                cardioFitnessRow(level)
            }
            .removeListRowFormatting()
        } header: {
            Text("How would you rate your cardiovascular fitness?")
        } footer: {
            Text("Consider your ability to maintain sustained cardio activities like running, cycling, or swimming.")
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
    
    private func cardioFitnessRow(_ level: CardioFitnessLevel) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(level.description)
                    .font(.headline)
                Text(level.detailDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: presenter.selectedCardioFitness == level ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(presenter.selectedCardioFitness == level ? Color.accent : Color.secondary)
        }
        .padding()
        .background(colorScheme.backgroundPrimary)
        .anyButton(.press) {
            presenter.selectedCardioFitness = level
        }
    }
}

extension CoreBuilder {
    func cardioFitnessView(router: AnyRouter, delegate: CardioFitnessDelegate) -> some View {
        CardioFitnessView(
            presenter: CardioFitnessPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showCardioFitnessView(delegate: CardioFitnessDelegate) {
        router.showScreen(.push) { router in
            builder.cardioFitnessView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.cardioFitnessView(
            router: router,
            delegate: .mock
        )
    }
    
}
