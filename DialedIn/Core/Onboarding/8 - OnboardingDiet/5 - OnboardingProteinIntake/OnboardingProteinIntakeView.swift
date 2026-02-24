//
//  OnboardingProteinIntakeView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/10/2025.
//

import SwiftUI

struct OnboardingProteinIntakeView: View {

    @Environment(\.colorScheme) private var colorScheme
    @State var presenter: OnboardingProteinIntakePresenter

    var delegate: OnboardingProteinIntakeDelegate

    var body: some View {
        List {
            pickerSection
        }
        .navigationTitle("Protein Intake")
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.navigate(dietPlanBuilder: delegate.dietPlanBuilder)
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedProteinIntake == nil)
            .padding(.horizontal)
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
}

extension CoreBuilder {
    func onboardingProteinIntakeView(router: AnyRouter, delegate: OnboardingProteinIntakeDelegate) -> some View {
        OnboardingProteinIntakeView(
            presenter: OnboardingProteinIntakePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showOnboardingProteinIntakeView(delegate: OnboardingProteinIntakeDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingProteinIntakeView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingProteinIntakeView(
            router: router,
            delegate: OnboardingProteinIntakeDelegate(
                dietPlanBuilder: .proteinIntakeMock
            )
        )
    }
    
}
