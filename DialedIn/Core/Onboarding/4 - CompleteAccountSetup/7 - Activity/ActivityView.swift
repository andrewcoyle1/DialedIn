//
//  ActivityView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct ActivityDelegate {
    let gender: Gender
    let dateOfBirth: Date
    let heightInCentimetres: Double
    let lengthUnitPreference: LengthUnitPreference
    let weightInKilograms: Double
    let weightUnitPreference: WeightUnitPreference
    let exerciseFrequency: ExerciseFrequency
    
    init(delegate: ExerciseFrequencyDelegate, exerciseFrequency: ExerciseFrequency) {
        self.gender = delegate.gender
        self.dateOfBirth = delegate.dateOfBirth
        self.heightInCentimetres = delegate.heightInCentimetres
        self.lengthUnitPreference = delegate.lengthUnitPreference
        self.weightInKilograms = delegate.weightInKilograms
        self.weightUnitPreference = delegate.weightUnitPreference
        self.exerciseFrequency = exerciseFrequency
    }
    
    static var mock: Self {
        Self(delegate: .mock, exerciseFrequency: .daily)
    }
}

struct ActivityView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: ActivityPresenter

    var delegate: ActivityDelegate

    var body: some View {
        List {
            dailyActivitySection
        }
        .navigationTitle("Activity Level")
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.onContinuePressed(delegate: delegate)
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canSubmit)
            .padding(.horizontal)
        }
    }
    
    private var dailyActivitySection: some View {
        Section {
            ForEach(ActivityLevel.allCases, id: \.self) { level in
                activityRow(level)
            }
            .removeListRowFormatting()
        } header: {
            Text("What's your daily activity level outside of exercise?")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
    }
    
    private func activityRow(_ level: ActivityLevel) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(level.description)
                    .font(.headline)
                Text(level.detailDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: presenter.selectedActivityLevel == level ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(presenter.selectedActivityLevel == level ? Color.accent : Color.secondary)
        }
        .padding()
        .background(colorScheme.backgroundPrimary)
        .anyButton(.press) {
            presenter.selectedActivityLevel = level
        }
    }
}

extension CoreBuilder {
    func activityView(router: AnyRouter, delegate: ActivityDelegate) -> some View {
        ActivityView(
            presenter: ActivityPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showActivityView(delegate: ActivityDelegate) {
        router.showScreen(.push) { router in
            builder.activityView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.activityView(
            router: router,
            delegate: .mock
        )
    }
    
}
