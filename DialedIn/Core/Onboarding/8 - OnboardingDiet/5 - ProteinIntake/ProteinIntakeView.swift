//
//  ProteinIntakeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct ProteinIntakeDelegate {
    let preferredDiet: PreferredDiet
    let calorieFloor: CalorieFloor
    let calorieDistrubtion: CalorieDistribution
    
    init(delegate: CalorieDistributionDelegate, calorieDistribution: CalorieDistribution) {
        self.preferredDiet = delegate.preferredDiet
        self.calorieFloor = delegate.calorieFloor
        self.calorieDistrubtion = calorieDistribution
    }
    
    static var mock: Self {
        Self(delegate: .mock, calorieDistribution: .even)
    }
}

struct ProteinIntakeView: View {

    @Environment(\.colorScheme) private var colorScheme
    @State var presenter: ProteinIntakePresenter

    var delegate: ProteinIntakeDelegate

    var body: some View {
        List {
            pickerSection
        }
        .navigationTitle("Protein Intake")
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
            .disabled(presenter.selectedProteinIntake == nil)
        }
    }
    
    private var pickerSection: some View {
        Section {
            ForEach(ProteinIntake.allCases) { intake in
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(intake.description)
                            .font(.headline)
                        Text(intake.detailedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: presenter.selectedProteinIntake == intake ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(presenter.selectedProteinIntake == intake ? .accent : .secondary)
                }
                .padding()
                .background(colorScheme.backgroundPrimary)
                .onTapGesture { presenter.selectedProteinIntake = intake }
            }
            .removeListRowFormatting()
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
}

extension CoreBuilder {
    func proteinIntakeView(router: AnyRouter, delegate: ProteinIntakeDelegate) -> some View {
        ProteinIntakeView(
            presenter: ProteinIntakePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showProteinIntakeView(delegate: ProteinIntakeDelegate) {
        router.showScreen(.push) { router in
            builder.proteinIntakeView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.proteinIntakeView(
            router: router,
            delegate: .mock
        )
    }
    
}
